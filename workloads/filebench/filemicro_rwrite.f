#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2008 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# ident	"%Z%%M%	%I%	%E% SMI"

# Single threaded asynchronous ($sync) random writes (2KB I/Os) on a 1GB file.
# Stops when 128MB ($bytes) has been written.

set $dir=/mnt/test
set $bytes=192g
#set $cached=false
set $filesize=3g
set $iosize=4k
set $iters=1000
set $nthreads=64
set $sync=false
set $nfiles=64
set $meandirwidth=64

define fileset name=bigfileset, path=$dir,size=$filesize, prealloc, entries=$nfiles,dirwidth=$meandirwidth #cached=$cached

define process name=filewriter,instances=1
{
  thread name=filewriterthread,memsize=10m,instances=$nthreads
  {
    flowop write name=write-file,filename=bigfileset,random,dsync=$sync,iosize=$iosize,iters=$iters
    flowop finishonbytes name=finish,value=$bytes
  }
}

echo  "FileMicro-WriteRand Version 2.1 personality successfully loaded"
run 60
