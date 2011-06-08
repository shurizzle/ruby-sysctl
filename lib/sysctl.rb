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
  extend FFI::Library
  ffi_lib 'c'

  attach_function :sysctl, [ :pointer, :size_t, :pointer, :pointer, :pointer, :size_t ], :int

  class << self
    alias __c_sysctl__ sysctl
    private :__c_sysctl__
  end

  def self.sysctl (ctl)
    mib = CTL_NAMES[ctl]
    return unless mib

    type = mib.type.is_a?(Symbol) ? FFI.find_type(mib.type) : mib.type

    if type.is_a?(FFI::Type::Builtin) and type.name.downcase == :string
      tvp = FFI::MemoryPointer.from_string("\0" * 8192)
      tvs = FFI::MemoryPointer.new(:int).write_int(tvp.size)
    else
      tvp = FFI::MemoryPointer.new(type)
      tvs = FFI::MemoryPointer.new(:int).write_int(type.size)
    end

    mip = FFI::MemoryPointer.new(:int, mib.mib.size).write_array_of_int(mib.mib)

    raise Errno.const_get(Errno.constants[FFI.errno]) if __c_sysctl__(mip, mib.mib.size, tvp, tvs, nil, 0) != 0

    tvp.typecast(type)
  end
end

def sysctl (name)
  Sysctl.sysctl(name)
end

module Kernel
  def self.sysctl (name)
    Sysctl.sysctl(name)
  end
end

begin
  require "sysctl/platform/#{RUBY_PLATFORM.split('-').last}"
rescue LoadError
  raise "Platform not supported."
end
