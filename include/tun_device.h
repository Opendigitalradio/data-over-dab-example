/*
 *
 * Copyright (c) 2016, Felix Morgner
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Felix Morgner nor the names of its contributors may
 *    be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

/*
 * The 'tun_device' wrapper class is based on a wrapper for Linux tap devices
 * by Felix Morgner as used in 'tapper'.
 */

#ifndef __DOD_TUN_DEVICE
#define __DOD_TUN_DEVICE

#include <linux/if_tun.h>
#include <net/if.h>
#include <netinet/in.h>
#include <sys/ioctl.h>

#include <asio/io_service.hpp>
#include <asio/posix/stream_descriptor.hpp>

#include <array>
#include <functional>
#include <string>
#include <system_error>
#include <vector>

/**
 * @author Felix Morgner
 * @since 1.0
 *
 * A simple wrapper to handle tun device I/O using ASIO
 */
struct tun_device
  {
  /**
   * @author Felix Morgner
   * @since 1.0
   *
   * Create a tun device wrapper with a user provided name
   *
   * @param eventLoop The ASIO io_service to run I/O-operations on
   * @param name The name for the virtual tunnel device
   */
  tun_device(asio::io_service & eventLoop, std::string const & name);

  ~tun_device();

  /**
   * @author Felix Morgner
   * @since 1.0
   *
   * Enqueue data to be sent to the operating system
   *
   * @param data The data to send to the operation system
   */
  void enqueue(std::vector<unsigned char> && data);

  /**
   * @author Felix Morgner
   * @since 1.0
   *
   * Put the interface up
   *
   * @return A std::error_code of 0 on success, other values otherwise
   */
  std::error_code up();

  /**
   * @author Felix Morgner
   * @since 1.0
   *
   * Retrieve the actual name of the tun device
   *
   * The operating system is free to assign a name different from the one
   * desired by the user. This function returns the actual name the OS
   * assigned to the device.
   */
  std::string const & name() const;

  /**
   * @author Felix Morgner
   * @since 1.0
   *
   * Get the device address
   */
  std::string address();

  /**
   * @author Felix Morgner
   * @since 1.0
   *
   * Set the IPv4 address of the device.
   *
   * Currently only IPv4 addresses are supported and the netmask defaults to
   * /24.
   */
  std::error_code address(std::string const & address);

  private:
    void do_write(std::vector<unsigned char> && data);

    std::error_code ioctl(int const type, ifreq & request);

    asio::posix::stream_descriptor m_device;

    std::string m_name{};
    int m_ioctlDummy{-1};
  };

#endif

