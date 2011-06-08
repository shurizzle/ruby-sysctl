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
  end

  CTL_NAMES = CTLRoot.new([
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
end
