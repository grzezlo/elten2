#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Object
  include EltenAPI
end

module Elten
Version=2.4
Beta=30
Alpha=0
IsBeta=1
BuildID=20200402001
BuildDate=1586641595
class <<self
  def version
  return Version
end
def beta
  return Beta
end
def alpha
  return Alpha
end
def isbeta
  return IsBeta
end
def build_id
  return BuildID
end
def build_date
  t=Time.at(BuildDate)
  return sprintf("%04d-%02d-%02d %02d:%02d",t.year,t.month,t.day,t.hour,t.min)
  end
end
end
begin
Log.head("Starting Elten")
Log.head("Version: #{Elten.version.to_s}")
Log.head("Beta: #{Elten.beta.to_s}") if Elten.isbeta==1
if $ruby != true
    Graphics.freeze
  Graphics.update
        $volume=50 if $volume==nil
      $mainthread = Thread::current
$stopmainthread         = false
end
  $LOAD_PATH << "."
end
  begin
  #main
  # Make scene object (title screen)
    if $toscene != true
    $scene = Scene_Loading.new if $tomain == nil and $updating != true and $downloading != true and $beta_downloading != true
  $scene = Scene_Main.new if $tomain == true
  $scene = Scene_Update.new if $updating == true
  $scene = $scene if $downloading == true
  $scene = Scene_Beta_Downloaded.new if $beta_downloading == true
end
$toscene = false
  # Call main method as long as $scene is effective
  $dialogopened = false
  loop do
  $scene=Scene_Loading.new if $restart==true
          if $scene != nil and $exit!=true
        $notifications_callback = nil
        Log.debug("Loading scene: #{$scene.class.to_s}")
                              $scene.main
  else
    break
    end
  end
      play("logout")
  register_activity if $privacy_registeractivity==1
  delay(1)
  NVDA.join
  NVDA.destroy
    Win32API.new("kernel32","TerminateProcess",'ip','i').call($agent.pid,"") if $agent!=nil
    $agent=nil
    srvproc("chat", {"send"=>1, "text"=>p_("Chat", "Left the discussion.")}) if $chat==true
  speech_wait
  Log.debug("Closing processes")
  if $procs!=nil  
  for o in $procs
Win32API.new("kernel32","TerminateProcess",'ip','i').call(o,"")
    end
  end
    if $playlistbuffer != nil
$t=false
    begin      
      $playlistpaused=true    
      $playlistbuffer.pause if $t==false
    
    rescue Exception
      Log.warning("Failed to free playlist buffer")
    $t=true
    retry
    end
    end
  $playlist = [] if $playlist == nil
  if $playlist.size > 0
    $playlistpaused = true
        if FileTest.exists?("#{Dirs.eltendata}\\playlist.eps")
      pls = load_data("#{Dirs.eltendata}\\playlist.eps")
      if pls != $playlist
        if confirm(p_("*Main", "Your playlist has been changed. Save current changes?")) == 1
save_data($playlist,"#{Dirs.eltendata}\\playlist.eps")
          end
        end
      else
        if confirm(p_("*Main", "Do you want to save your playlist?")) == 1
          save_data($playlist,"#{Dirs.eltendata}\\playlist.eps")
          end
        end
        $playlist=[]
        $playlistbuffer.close if $playlistbuffer==nil
        $playlistbuffer=nil
        else
    if FileTest.exists?("#{Dirs.eltendata}\\playlist.eps")
      if confirm(p_("*Main", "Do you want to delete the saved playlist?")) == 1
        File.delete("#{Dirs.eltendata}\\playlist.eps")
        end
            end
  end
  deldir($tempdir)
    $exit = true
  if $exitupdate==true
    writefile(Dirs.eltendata+"\\update.last",Zlib::Deflate.deflate([$version.to_s,$beta.to_s,$alpha.to_s,$isbeta.to_s].join(" ")))
    writefile(Dirs.eltendata+"\\bin\\Data\\update.last",Marshal.dump(Time.now.to_f))
    exit(run("\"#{Dirs.eltendata}\\eltenup.exe\" /tasks=\"\" /silent"))
  end
  Log.info("Exiting Elten")
          rescue Hangup
  Graphics.update if $ruby != true
  $toscene = true
  retry
rescue Reset
key_update
  $DEBUG=true if $key[0x10]
  play("signal") if $key[0x10]
  retry
  rescue SystemExit
  loop_update
  quit if $keyr[0x73]
          play("list_focus") if $exit==nil
  $toscene = true
    retry if $exit == nil
    end;begin
  rescue Exception
      if $ruby != true
  if $updating != true and $beta_downloading != true and $start != nil and $downloading != true
        speech("Critical error occurred: "+$!.message)
    speech_wait
    sleep(0.5)
    speech("Do you want to send the errror report?")
    speech_wait
    if selector(["No","Yes"])== 1
      sleep(0.15)
      bug
    end
sel = menulr(["Copy error report to clipboard","Restart","Try again","Rescue mode","Abort"],true,0,"What to do?")
loop do
  loop_update
  sel.update
  if enter
    if sel.index > 0
    break
  else
    msg = $!.to_s+"\r\n"+$@.to_s
    Clipboard.set_data(msg)
    speech("Copied to clipboard")
    end
  end
  end
    case sel.index
    when 1
      $toscene = false
      retry
      when 2
        $toscene = true
        retry
    when 3
      speech("Rescue mode")
      speech_wait
      @sels = ["Quit", "Reinstall"]
      @sels += ["Try to open forum", "Try to open messages"] if Session.name != nil and Session.name != ""
      @sel = menulr(@sels)
      loop do
        loop_update
        @sel.update
        if enter
          break
        end
      end
      case @sel.index
      when 0
              fail
        when 1
        $scene = Scene_Update.new
        $toscene = true
        retry
        when 2
          insert_scene($scene) if $scenes != nil
          $scene = Scene_Forum.new
                    $toscene = true
                    retry
          when 3
            insert_scene($scene) if $scenes != nil
            $scene = Scene_Messages.new
            $toscene = true      
            retry
      end
        when 4
    fail if $DEBUG == true
  end
  end
  if $updating == true
    retry
  end
  if $beta_downloading == true
    retry
  end
  if $start == nil
    retry
  end
else
  fail
  end
end