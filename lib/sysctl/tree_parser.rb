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

module Sysctl
  class MIB < Struct.new(:mib, :type)
    def initialize (mib, type=nil)
      self.mib = mib
      self.type = type
    end

    alias __set_type__ type=
    def type= (type)
      self.__set_type__(type || :int)
    end

    def << (mib)
      self.mib << mib
    end
  end

  class CTLRoot
    def initialize (children=nil)
      @children = {}

      if children.is_a?(Array)
        children.each {|child|
          self << (child.is_a?(CTLNode) ? child : CTLNode.new(*child))
        }
      end
    end

    def << (node)
      return unless node.is_a?(CTLNode)
      @children[node.name] = node
      self
    end

    def children
      @children
    end

    def [] (name)
      tree = name.downcase.split('.')

      mib, * = tree.inject([MIB.new([]), self.children]) {|(mib, node), point|
        node = node[point]
        mib << node.value
        mib.type = node.type
        [mib, node]
      }

      mib.mib = mib.mib.compact.flatten
      mib
    rescue
      nil
    end
  end

  class CTLNode
    attr_reader :name, :value, :type

    def initialize (name, value, type=:int, children=nil)
      @name, @value, @type = name, value, type || :int

      @children = {}

      if children.is_a?(Array)
        children.each {|child|
          self << (child.is_a?(CTLNode) ? child : CTLNode.new(*child))
        }
      end
    end

    def << (node)
      return unless node.is_a?(CTLNode)
      @children[node.name] = node
      self
    end

    def children
      @children.dup
    end

    def [] (name)
      @children[name]
    end
  end
end
