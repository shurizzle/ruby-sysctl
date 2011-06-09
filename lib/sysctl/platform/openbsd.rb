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

require 'sysctl/tree_parser'

module Sysctl
  FFI.typedef(:uint32, :fixpt_t)

  class LoadAVG < FFI::Struct
    layout \
      :ldavg, [:fixpt_t, 3],
      :fscale, :long

    memoize
    def ldavg
      self[:ldavg].to_a
    end

    memoize
    def fscale
      self[:fscale]
    end
  end

  class VMTotal < FFI::Struct
    layout \
      :t_rq, :uint16,
      :t_dw, :uint16,
      :t_pw, :uint16,
      :t_sl, :uint16,
      :t_sw, :uint16,
      :t_vm, :uint32,
      :t_avm, :uint32,
      :t_rm, :uint32,
      :t_arm, :uint32,
      :t_vmshr, :uint32,
      :t_avmshr, :uint32,
      :t_rmshr, :uint32,
      :t_armshr, :uint32,
      :t_free, :uint32
  end

  class PSStrings < FFI::Struct
    layout \
      :ps_argvstr, :pointer,
      :ps_nargvstr, :int,
      :ps_envstr, :pointer,
      :ps_nenvstr, :int

    memoize
    def argvstr
      size = FFI.find_type(:pointer)

      (0...self[:ps_nargvstr]).map {|i|
        self[:ps_argvstr].get_pointer(i * size).read_string
      }
    end

    memoize
    def envstr
      size = FFI.find_type(:pointer)

      (0...self[:ps_nenvstr]).map {|i|
        self[:ps_envstr].get_pointer(i * size).read_string
      }
    end
  end

  class UVMexP < FFI::Struct
    layout \
      :pagesize, :int,
      :pagemask, :int,
      :pageshift, :int,
      :npages, :int,
      :free, :int,
      :active, :int,
      :inactive, :int,
      :paging, :int,
      :wired, :int,
      :zeropages, :int,
      :reserve_pagedaemon, :int,
      :reserve_kernel, :int,
      :anonpages, :int,
      :vnodepages, :int,
      :vtextpages, :int,
      :freemin, :int,
      :freetarg, :int,
      :inactarg, :int,
      :wiredmax, :int,
      :anonmin, :int,
      :vtextmin, :int,
      :vnodemin, :int,
      :anonminpct, :int,
      :vtextminpct, :int,
      :vnodeminpct, :int,
      :nswapdev, :int,
      :swpages, :int,
      :swpginuse, :int,
      :swpgonly, :int,
      :nswget, :int,
      :nanon, :int,
      :nanonneeded, :int,
      :nfreeanon, :int,
      :faults, :int,
      :traps, :int,
      :intrs, :int,
      :swtch, :int,
      :softs, :int,
      :syscalls, :int,
      :pageins, :int,
      :swapins, :int,
      :swapouts, :int,
      :pgswapin, :int,
      :pgswapout, :int,
      :forks, :int,
      :forks_ppwait, :int,
      :forks_sharevm, :int,
      :pga_zerohit, :int,
      :pga_zeromiss, :int,
      :zeroaborts, :int,
      :fltnoram, :int,
      :fltnoanon, :int,
      :fltpgwait, :int,
      :fltpgrele, :int,
      :fltrelck, :int,
      :fltrelckok, :int,
      :fltanget, :int,
      :fltanretry, :int,
      :fltamcopy, :int,
      :fltnamap, :int,
      :fltnomap, :int,
      :fltlget, :int,
      :fltget, :int,
      :flt_anon, :int,
      :flt_acow, :int,
      :flt_obj, :int,
      :flt_prcopy, :int,
      :flt_przero, :int,
      :pdwoke, :int,
      :pdrevs, :int,
      :pdswout, :int,
      :pdfreed, :int,
      :pdscans, :int,
      :pdanscan, :int,
      :pdobscan, :int,
      :pdreact, :int,
      :pdbusy, :int,
      :pdpageouts, :int,
      :pdpending, :int,
      :pddeact, :int,
      :pdreanon, :int,
      :pdrevnode, :int,
      :pdrevtext, :int,
      :fpswtch, :int,
      :kmapent, :int
  end

  SensorStatus = FFI::Enum.new([
    :unspec,
    :ok,
    :warn,
    :crit,
    :unknown
  ])

  SensorType = FFI::Enum.new([
    :temp,
    :fanrpm,
    :volts_dc,
    :volts_ac,
    :ohms,
    :watts,
    :amps,
    :watthour,
    :amphour,
    :indicator,
    :integer,
    :percent,
    :lux,
    :drive,
    :timedelta,
    :humidity,
    :freq,
    :angle
  ])

  class << SensorType
    TYPES = [
      "temp",
      "fan",
      "volt",
      "acvolt",
      "resistance",
      "power",
      "current",
      "watthour",
      "amphour",
      "indicator",
      "raw",
      "percent",
      "illuminance",
      "drive",
      "timedelta",
      "humidity",
      "frequency",
      "angle"
    ]

    def from_num(n)
      TYPES[n] || 'unknown'
    end
  end

  class TimeVal < FFI::Struct
    layout \
      :tv_sec, :long,
      :tv_usec, :long
  end

  class Sensor < FFI::Struct
    FINVALID = 1
    FUNKNOWN = 2

    layout \
      :desc, [:char, 32],
      :tv, TimeVal,
      :value, :int64,
      :type, SensorType,
      :status, SensorStatus,
      :numt, :int,
      :flags, :int

    memoize
    def desc
      self[:desc].to_s
    end
  end

  class SensorDev < FFI::Struct
    layout \
      :num, :int,
      :xname, [:char, 16],
      :maxnumt, [:int, 18],
      :sensors_count, :int

    memoize
    def maxnumt
      self[:maxnumt].to_a
    end

    memoize
    def xname
      self[:xname].to_s
    end
  end

  CTL_NAMES = CTLRoot.new([
    ['vm', 2, :node,
      [
        ['vmmeter', 1, VMTotal],
        ['loadavg', 2, LoadAVG],
        ['psstrings', 3, PSStrings],
        ['uvmexp', 4, UVMexP],
        ['swapencrypt', 5, :node],
        ['nkmempages', 6],
        ['anonmin', 7],
        ['vtextmin', 8],
        ['vnodemin', 9],
        ['maxslp', 10],
        ['uspace', 11]
      ]
    ],

    ['fs', 3, :node,
      [
        ['posix', nil, :node, [
          ['setuid', 1]
        ]]
      ]
    ],

    ['hw', 6, :node,
      [
        ['machine', 1, :string],
        ['model', 2, :string],
        ['ncpu', 3],
        ['byteorder', 4],
        ['pagesize', 7],
        ['disknames', 8, :string],
        ['diskstats', 9, :struct],
        ['diskcount', 10],
        ['sensors', 11, :node],
        ['cpuspeed', 12],
        ['setperf', 13],
        ['vendor', 14, :string],
        ['product', 15, :string],
        ['version', 16, :string],
        ['serialno', 17, :string],
        ['uuid', 18, :string],
        ['physmem', 10],
        ['usermem', 20],
        ['ncpufound', 21]
      ]
    ],

    ['user', 8, :node,
      [
        ['cs_path', 1, :string],
        ['bc_base_max', 2],
        ['bc_dim_max', 3],
        ['bc_scale_max', 4],
        ['bc_string_max', 5],
        ['coll_weights_max', 6],
        ['expr_nest_max', 7],
        ['line_max', 8],
        ['re_dup_max', 9],
        ['posix2_version', 10],
        ['posix2_c_bind', 11],
        ['posix2_c_dev', 12],
        ['posix2_char_term', 13],
        ['posix2_fort_dev', 14],
        ['posix2_fort_run', 15],
        ['posix2_localedef', 16],
        ['posix2_sw_dev', 17],
        ['posix2_upe', 18],
        ['stream_max', 19],
        ['tzname_max', 20]
      ]
    ],

    ['ddb', 9, :node,
      [
        ['radix', 1],
        ['maxwidth', 2],
        ['maxline', 3],
        ['tabstop', 4],
        ['panic', 5],
        ['console', 6],
        ['log', 7],
        ['trigger', 8],
        ['maxid', 9]
      ]
    ]
  ])

  CTL_NAMES['hw.sensors'].tap {|mib|
    (0..Float::INFINITY).each {|i|
      mip = FFI::MemoryPointer.new(:int, mib.mib.size + 1).write_array_of_int(mib.mib + [i])
      tvp = FFI::MemoryPointer.new(SensorDev)
      tvs = FFI::MemoryPointer.new(:int).write_int(SensorDev.size)

      unless C.sysctl(mip, mib.mib.size + 1, tvp, tvs, nil, 0).zero?
        break if FFI.errno == 2
        next if FFI.errno == 6
      end

      s = tvp.typecast(SensorDev)
      CTL_NAMES.children['hw']['sensors'] << CTLNode.new(s.xname, i, SensorDev)

      s.maxnumt.each_with_index {|n, j|
        name = SensorType.from_num(j)

        0.upto(n - 1) {|x|
          CTL_NAMES.children['hw']['sensors'][s.xname] << CTLNode.new("#{name}#{x}", [j, x], Sensor)
        }
      }
    }
  }

  def self.sysctl (ctl)
    mib = CTL_NAMES[ctl] or return

    type = mib.type.is_a?(Symbol) ? FFI.find_type(mib.type) : mib.type

    if type.is_a?(FFI::Type::Builtin) and type.name.downcase == :string
      tvp = FFI::MemoryPointer.new(8192)
      tvs = FFI::MemoryPointer.new(:int).write_int(tvp.size)
    else
      tvp = FFI::MemoryPointer.new(type)
      tvs = FFI::MemoryPointer.new(:int).write_int(type.size)
    end

    mip = FFI::MemoryPointer.new(:int, mib.mib.size).write_array_of_int(mib.mib)

    if C.sysctl(mip, mib.mib.size, tvp, tvs, nil, 0) != 0
      raise Errno.const_get(Errno.constants[FFI.errno])
    end

    tvp.typecast(type)
  end
end
