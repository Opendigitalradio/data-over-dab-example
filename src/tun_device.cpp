#include "tun_device.h"

#include <asio/write.hpp>

#include <iostream>

tun_device::tun_device(asio::io_service & eventLoop, std::string const & name)
  : m_device{eventLoop}
  {
  auto descriptor = int{};
  if((descriptor = open("/dev/net/tun", O_RDWR)) < 0)
    {
    throw std::error_code{errno, std::system_category()};
    }

  auto request = ifreq{};
  request.ifr_flags = IFF_TUN | IFF_NO_PI;
  std::strncpy(request.ifr_name, name.c_str(), IFNAMSIZ);

  if(::ioctl(descriptor, TUNSETIFF, &request) < 0)
    {
    throw std::error_code{errno, std::system_category()};
    }

  m_name = request.ifr_name;
  m_device.assign(descriptor);
  m_ioctlDummy = socket(AF_INET, SOCK_DGRAM, 0);
  }

tun_device::~tun_device()
  {
  if(m_ioctlDummy >= 0)
    {
    close(m_ioctlDummy);
    }
  }

std::error_code tun_device::up()
  {
  auto request = ifreq{};
  request.ifr_flags = IFF_UP;
  std::strncpy(request.ifr_name, m_name.c_str(), IFNAMSIZ);
  return ioctl(SIOCSIFFLAGS, request);
  }

void tun_device::enqueue(std::vector<unsigned char> && data)
  {
  do_write(std::move(data));
  }

std::string const & tun_device::name() const
  {
  return m_name;
  }

std::error_code tun_device::address(std::string const & address)
  {
  auto requestedAddress = sockaddr_in{};
  requestedAddress.sin_family = AF_INET;
  inet_pton(AF_INET, address.c_str(), &requestedAddress.sin_addr);

  auto request = ifreq{};
  std::strncpy(request.ifr_name, m_name.c_str(), IFNAMSIZ);
  request.ifr_addr = *reinterpret_cast<sockaddr *>(&requestedAddress);
  auto error = ioctl(SIOCSIFADDR, request);

  if(!error)
    {
    auto netmask = sockaddr_in{};
    netmask.sin_family = AF_INET;
    inet_pton(AF_INET, "255.255.255.0", &netmask.sin_addr);

    auto request = ifreq{};
    std::strncpy(request.ifr_name, m_name.c_str(), IFNAMSIZ);
    request.ifr_addr = *reinterpret_cast<sockaddr *>(&netmask);

    return ioctl(SIOCSIFNETMASK, request);
    }

  return error;
  }

std::string tun_device::address()
  {
  auto request = ifreq{};
  std::strncpy(request.ifr_name, m_name.c_str(), IFNAMSIZ);
  request.ifr_addr.sa_family = AF_INET;

  auto address = std::string{};
  if(!ioctl(SIOCGIFADDR, request))
    {
    char buffer[INET_ADDRSTRLEN];
    if(inet_ntop(AF_INET, &(reinterpret_cast<sockaddr_in *>(&request.ifr_addr))->sin_addr, buffer, sizeof(buffer)))
      {
      address = buffer;
      }
    }

  return address;
  }

void tun_device::do_write(std::vector<unsigned char> && data)
  {
  asio::async_write(m_device, asio::buffer(data), [&, data](std::error_code const & error, std::size_t const){
    if(error)
      {
      std::cerr << "Failed to write " << data.size() << " bytes to virtual interface!\n";
      }
    });
  }

std::error_code tun_device::ioctl(int const type, ifreq & request)
  {
  if(m_ioctlDummy >= 0)
    {
    if(::ioctl(m_ioctlDummy, type, &request) < 0)
      {
      return {errno, std::system_category()};
      }
    else
      {
      return {};
      }
    }
  else
    {
    return {ENOTCONN, std::system_category()};
    }
  }
