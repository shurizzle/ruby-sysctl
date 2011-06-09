#--
# Copyleft shura. [ shura1991@gmail.com ]
#
# This file is part of sysctl.
#
# sysctl is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# sysctl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with sysctl. If not, see <http://www.gnu.org/licenses/>.
#++

require 'sysctl/extensions'

module Sysctl
  module C
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    attach_function! :sysctl,  [:pointer, :size_t, :pointer, :pointer, :pointer, :size_t], :int

    attach_function! :sysconf, [:int], :long
  end

  def self.sysctl (*args)
    nil
  end

  begin
    require "sysctl/platform/#{RUBY_PLATFORM.split('-').last.match(/^[a-z]+/i)[0]}"
    @@supported = true
  rescue LoadError
    warn 'sysctl: platform not supported.'
    @@supported = false
  end

  def self.supported?
    @@supported
  end
end

def sysctl (*args, &block)
  Sysctl.sysctl(*args, &block)
end

module Kernel
  def self.sysctl (*args, &block)
    Sysctl.sysctl(*args, &block)
  end
end


