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

require 'ffi'
require 'memoized'

module FFI
  module Library
    def has_function? (sym, libraries=[])
      if libraries.empty?
        libraries << FFI::Library::LIBC
      end

      libraries.any? {|lib|
        DynamicLibrary.new(lib, 0).find_function(sym.to_s) rescue nil
      }
    end

    def attach_function! (*args, &block)
      begin
        attach_function(*args, &block)
      rescue Exception => e
        false
      end
    end
  end

  class Type::Builtin
    memoize
    def name
      Type::Builtin.constants.find {|name|
        Type::Builtin.const_get(name) == self
      }
    end
  end

  class Pointer
    def typecast (type)
      if type.is_a?(Symbol)
        type = FFI.find_type(type)
      end

      if type.is_a?(Class) and type.ancestors.member?(FFI::Struct)
        type.new(self)
      elsif type.is_a?(Type::Builtin)
        if type.name == :STRING
          read_string
        else
          send "read_#{type.name.downcase}"
        end
      else
        ArgumentError.new "You have to pass a Struct, a Builtin type or a Symbol"
      end
    end
  end
end

FFI.find_type(:size_t) rescue FFI.typedef(:ulong, :size_t)
