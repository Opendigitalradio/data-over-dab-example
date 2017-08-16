/*
 * Copyright (C) 2017 Opendigitalradio (http://www.opendigitalradio.org/)
 * Copyright (C) 2017 Felix Morgner <felix.morgner@hsr.ch>
 * Copyright (C) 2017 Tobias Stauber <tobias.stauber@hsr.ch>
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
