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
# Copyright 2009 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# This workloads emulates a video server. It has two filesets, one of videos
# being actively served, and one of videos availabe but currently inactive
# (passive). However, one thread, vidwriter, is writing new videos to replace
# no longer viewed videos in the passive set. Meanwhile $nthreads threads are
# serving up videos from the activevids fileset. If the desired rate is R mb/s,
# and $nthreads is set to T, then set the $srvbwrate to R * T to get the
# desired rate per video stream. The video replacement rate of one video
# file per replacement interval, is set by $repintval which defaults to
# 10 seconds. Thus the write bandwidth will be set as $filesize/$repintval.
#

set $dir=/mnt/test
set $eventrate=96
set $filesize=512m
set $nthreads=64
set $numactivevids=21
set $numpassivevids=43
set $reuseit=false
set $readiosize=256k
set $writeiosize=4k

set $passvidsname=passivevids
set $actvidsname=activevids

set $repintval=10

eventgen rate=$eventrate

define fileset name=$actvidsname,path=$dir,size=$filesize,entries=$numactivevids,dirwidth=4,prealloc,paralloc,reuse=$reuseit
define fileset name=$passvidsname,path=$dir,size=$filesize,entries=$numpassivevids,dirwidth=20,prealloc=100,paralloc,reuse=$reuseit

define process name=vidwriter,instances=43
{
  thread name=vidwriter,instances=1
  {
   #flowop deletefile name=vidremover,filesetname=$passvidsname
   #flowop createfile name=wrtopen,filesetname=$passvidsname,fd=1
   #flowop writewholefile name=newvid,random, iosize=$writeiosize,fd=1,srcfd=1
   flowop write name=newvid,filesetname=$passvidsname,random,iosize=$writeiosize,directio
   #flowop closefile name=wrtclose, fd=1
   #flowop delay name=replaceinterval, value=$repintval
  }
}

define process name=vidreaders,instances=21
{
  thread name=vidreaders,instances=1
  {
    flowop read name=vidreader,filesetname=$actvidsname,iosize=$readiosize,directio
    flowop bwlimit name=serverlimit, target=vidreader
  }
}

echo  "Video Server Version 3.0 personality successfully loaded"
run 60
