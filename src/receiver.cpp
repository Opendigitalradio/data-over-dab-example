#include "tun_device.h"

#include <dabdecode.h>
#include <dabip.h>
#include <demodulator.h>
#include <device/device.h>
#include <device/rtl_device.h>
#include <types/common_types.h>

#include <asio/io_service.hpp>

#include <cstdint>
#include <future>
#include <iostream>

int main(int argc, char * * argv)
  {

  // Very crude argument handling. DON'T USE THIS IN PRODUCTION!
  if(argc != 3)
    {
    std::cerr << "usage: data_over_dab <destination_ip> <packet_address>\n";
    return 1;
    }

  // Prepare are data queues for acquisition and demodulation
  dab::sample_queue_t samples{};
  dab::symbol_queue_t symbols{};

  // Make _kHz and co usable
  using namespace dab::literals;

  // Prepare the input device
  dab::rtl_device device{samples};
  device.enable(dab::device::option::automatic_gain_control);
  device.tune(218640_kHz);

  // Start sample acquisition
  auto deviceRunner = std::async(std::launch::async, [&]{ device.run(); });

  // Initialize the demodulator
  dab::demodulator demod{samples, symbols, dab::transmission_modes::kTransmissionMode1};
  auto demodRunner = std::async(std::launch::async, [&]{ demod.run(); });

  // Create an io_service for our virtual network device
  asio::io_service eventLoop{};

  // We need a dummy load or else the io_service run() function return immediately
  asio::io_service::work dummyLoad{eventLoop};
  auto tunRunner = std::async(std::launch::async, [&]{ eventLoop.run(); });

  // Create our virtual network device
  tun_device tunnel{eventLoop, "dabdata"};
  auto destination = std::string{argv[1]};
  tunnel.address(destination);
  auto error = tunnel.up();
  if(error)
    {
    throw error.message();
    }

  // Initialize the decoder
  auto ensemble = dab::ensemble{symbols, dab::transmission_modes::kTransmissionMode1};

  // Prepare our packet parser
  auto packetParser = dab::packet_parser{std::uint16_t(std::stoi(argv[2]))};

  // Get the ensemble ready
  while(!ensemble && ensemble.update());

  // Check if we were able to succcessfully prepare the ensemble
  if(!ensemble)
    {
    return 1;
    }

  // Activate our service
  bool activated{};
  if(!activated)
    {
    for(auto const & service : ensemble.services())
      {
      // Check for a data service with a valid primary service component
      if(service.second->type() == dab::service_type::data && service.second->primary())
        {
        // Check if the primary service component claims to carry IPDT
        if(service.second->primary()->type() == 59)
          {
          // Register our "data received" callback with the service
          ensemble.activate(service.second, [&](std::vector<std::uint8_t> data){
            // Parse the received data
            auto parseResult = packetParser.parse(data);
            if(parseResult.first == dab::parse_status::ok)
              {
              // Parse the received data back into an MSC data group
              auto datagroupParser = dab::msc_data_group_parser{};
              parseResult = datagroupParser.parse(parseResult.second);

              if(parseResult.first == dab::parse_status::ok)
                {
                // Enqueue the data to be sent to the operating system
                tunnel.enqueue(std::move(parseResult.second));
                }
              else
                {
                std::cout << "datagroupError: " << std::uint32_t(parseResult.first) << '\n';
                }
              }
            else if(parseResult.first != dab::parse_status::incomplete)
              {
              std::cout << "packetError: " << std::uint32_t(parseResult.first) << '\n';
              }

            });

          // Prevent infinite reactivation loops
          activated = true;
          }
        }
      }
    }

  // Consume data as long as something comes in
  while(ensemble.update())
    {

    }
  }

