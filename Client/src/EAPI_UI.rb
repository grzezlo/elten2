#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module UI
    @@altdowntime=0
    private
# User interface related functions
    # Plays a soundtheme sound
    #
    # @param voice [String] a voice name
    # @param volume [Numeric] the volume
    # @param pitch [Numeric] the pitch
    # @example
    #  play("list_focus",80,100)
    def eplay(voice,volume=100,pitch=100)
                        if $interface_soundthemeactivation != 0 or FileTest.exists?(voice)
                          if $soundthemesounds==nil or $soundthemesoundspath!=$soundthemepath
                            if $soundthemesounds!=nil
                              $soundthemesounds.values.each {|s| s.close if s!=nil}
                              end
                            $soundthemesounds={}
                            $soundthemesoundspath=$soundthemepath
                            end
                          b=nil
                        if volume >= 0
                          volume = (volume.to_f * $volume.to_f / 100.0)
                        volume = 100 if volume > 100
                          volume = 1 if volume < 1
                                                volume = volume.to_i
                                              else
                                                volume = volume * -1
                                                volume = 100 if volume > 100
                                              end
                                              if $soundthemesounds[voice]==nil or $soundthemesounds[voice].closed
                        if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.ogg")
                          b=Bass::Sound.new("#{$soundthemepath}/SE/#{voice}.ogg",0)
                        end
                                                if b==nil&&FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.ogg")
                                                  $bgs.close if $bgs!=nil
                          b=$bgs=Bass::Sound.new("#{$soundthemepath}/BGS/#{voice}.ogg",0,true)
                                                  end
                                                if b==nil and FileTest.exist?("Audio/SE/#{voice}.ogg")
                          b=Bass::Sound.new("Audio/SE/#{voice}.ogg",0)
                        end
                                                if b==nil and FileTest.exist?("Audio/BGS/#{voice}.ogg")
                                                  $bgs.close if $bgs!=nil
                          b=$bgs=Bass::Sound.new("Audio/BGS/#{voice}.ogg",0,true)
                        end
                        if b==nil and FileTest.exist?(voice)
                          b=Bass::Sound.new(voice,0)
                        end
                        $soundthemesounds[voice]=b
                      else
                        b=$soundthemesounds[voice]
                        end
                        if b!=nil
                          b.newchannel
                                                  b.volume=volume.to_f/100.0*0.5
                                                                                                                                                                                                      b.play
                        end
                        end
                      end
                      
                      def play(*arg)
                        eplay(*arg)
                        end

                      # The keyboard related functions                      
# Determines if escape has been pressed
#
# @return [Boolean] returns true if escape was pressed, otherwise returns false
  def escape
                              return $key[0x1B]
    end
    
    # Determines if alt has been pressed
#
# @return [Boolean] returns true if alt was pressed, otherwise returns false
    def alt
      if (@@altdowntime||0)<Time.now.to_f-1
      @@altdown||=false
      @@altdowntime=Time.now.to_f
      return false
      end
      @@altdown=true if $keypr[0x12]
      @@altdown=false if $keyr[0x11]
              l=$keyu[0x12]&&@@altdown
              @@altdowntime=0 if l
    return l
    end
       
    # Determines if enter has been pressed
#
# @return [Boolean] returns true if enter was pressed, otherwise returns false
    def enter
      if $enter.is_a?(Integer)
        if $enter > 0
        $enter -= 1
        $key[0xD]=true
        end
        end
    key_update if $key==nil
    return $key[0xD]
    end
    
    # Determines if spacebar has been pressed
#
# @return [Boolean] returns true if spacebar was pressed, otherwise returns false
        def space
return $key[0x20]
end

def arrow_left(repeat=false)
  if repeat
    return $keyr[0x25]
    else
  return $key[0x25]
  end
end

def arrow_up(repeat=false)
  if repeat
    return $keyr[0x26]
    else
  return $key[0x26]
  end
end

def arrow_right(repeat=false)
  if repeat
    return $keyr[0x27]
    else
  return $key[0x27]
  end
end

def arrow_down(repeat=false)
  if repeat
    return $keyr[0x28]
    else
  return $key[0x28]
  end
end
  
  # Updates the keyboard state
       def key_update
         if $nextkey!=nil and $nextkeyr!=nil and $nextkeypr!=nil
           $key, $keyr, $keypr = $nextkey, $nextkeyr, $nextkeypr
           $nextkey, $nextkeyr, $nextkeypr = nil, nil, nil
           return
           end
         lkey=$key
              $key = Array.new(256)
              $keyu = Array.new(256)
     $keyr ||= Array.new(256)
     $keypr = []
                         $keybd="\0"*256
          Win32API.new("user32","GetKeyboardState",'p','i').call($keybd)
     bd=$keybd.unpack("c"*256)
          k="\0"*256
Win32API.new($eltenlib, "getkeys", 'p', 'i').call(k)
d=k.unpack("c"*256)
tokeys=[]
if NVDA.check
  g=NVDA.getgestures
  for k in g
        k=k.downcase
        if k=='kb(laptop):nvda+a' or k=='kb(desktop):nvda+downarrow'
          tokeys.push(0x2D,0x28)
          elsif k=='kb(laptop):nvda+l' or k=='kb(desktop):nvda+uparrow'
          tokeys.push(0x2D,0x26)
            end
  end
  end
  for i in 0..255
      if ((d[i]&1)>0 or tokeys.include?(i)) and (lkey==nil or i<32 or lkey[i]==false)
    $key[i]=true
            $keypr[i]=true if (d[i]&4)==0
                  else
    $key[i]=false
    $keypr[i]=false
  end
  if (d[i]&2>0)
    $keyu[i]=true
  else
    $keyu[i]=false
    end
  if bd[i]<0 or tokeys.include?(i)
   $keyr[i]=true
 elsif $key[i] and i<32
bd[i]=-128
else
  $keyr[i]=false
   end
  end
          $key[0x12]=true if $keyr[0x12]
          $key[0x10]=true if $keyr[0x10]
          $key[0x11]=true if $keyr[0x11]
          $keybd=bd.pack("c"*256)
        end                      
                    
                    def keyprocs
                  if $ruby != true or $windowminimized != true
                  if $keypr[0x11]
                    speech_stop(false)
                    $speech_wait = false
                    end
                  if !GlobalMenu.opened? && alt
                   GlobalMenu.show
                 end
                 if !GlobalMenu.opened? && $key[0x5D]
                   GlobalMenu.show(false)
                    end
  if $key[0x70]
  if $keyr[0x10]
        if $voice==-1
      $voice=readconfig("Voice","Voice",-1)
          elsif Win32API.new("bin\\screenreaderapi","getCurrentScreenReader",'','i').call>0
      $voice=-1
      end
  if $voice==-1
        alert(p_("EAPI_Common", "Using a screenreader"), false)
    else
    alert(p_("EAPI_Common", "Using a selected SAPI synthesizer"), false)
  end
else
  insert_scene(Scene_ShortKeys.new) if $scene.is_a?(Scene_ShortKeys)==false
      end
  end
  if $key[0x71]
  if $keyr[0x10]
GlobalMenu.show
  end
    end
  if $key[0x7B]
    confirm("Do you want to restart Elten?") {$reset=true}
  end
  ac=QuickActions.get
  for i in 1..12
    k=0x6F+i
    if $key[k]
      l=i
      l*=-1 if $keyr[0x10]
            for a in ac
        a.call if a.key==l
        end
      end
    end
  end
end
                    
                    # Updates a window, speech api and keyboard state
     def loop_update
       if $reset==true
         if Thread::current!=$mainthread
           exit
         else
                      raise(Reset,"")
           end
         end
                     exit if $exitproc==true
        if $exitupdate==true
       $scene=nil
       speech_stop
       end
       if $ruby == true
       while $windowminimized==true
                  sleep(0.1)
         end
       end
       tr = false
       if $trayreturn==true
         Log.info("Restored from tray")
         tr=true
end
if $agent!=nil and (av=$agent.avail)>0
              str=StringIO.new($agent.read(av))
      while str.pos<str.string.size-1
                                                                                                                                        d=Marshal.load(str)
                                                                                                                                                if d['func']=="notif"
                                    if $notifications_callback!=nil
                    $notifications_callback.call(d)
                  else
                    process_notification(d)
                    end
                  elsif d['func']=='srvproc'
                    $agids.delete(d['id'])
                                                  $eresps[d['id']]=d
                                                elsif d['func']=="eltsock_create"
                                                  $eltsocks_create||={}
                                                  $eltsocks_create[d['id']]=d
                                                elsif d['func']=="eltsock_write"
                                                  $eltsocks_write||={}
                                                  $eltsocks_write[d['id']]=d
                                                elsif d['func']=="eltsock_read"
                                                  $eltsocks_read||={}
                                                  $eltsocks_read[d['id']]=d
                                                elsif d['func']=="eltsock_close"
                                                  $eltsocks_close||={}
                                                  $eltsocks_close[d['id']]=d
                                                                                                            elsif d['func']=='tray'
                    $trayreturn=true
                  elsif d['func']=='alarm'
                    Log.info("Alarm")
                    $agalarm=true
                  elsif d['func']=='msg'
                                        $agent_msg=d['msgs'].to_i
                  elsif d['func']=='error'
                            e=d['msg']+"\r\n"+d['loc']
                            Log.error("Agent: #{e}")
if confirm(p_("EAPI_UI", " An unexpected error of Elten agent occurred. Do you want to report this event? It  may definitely help us solve the problem."))==1
    bug(false,"Elten Agent Error:\r\n"+e)
        end
alert(p_("EAPI_UI", "The program is trying to recover from the frozen state."))
elsif d['func']=='log'
  Log.add(d['level'], d['msg'], Time.at(d['time']))
elsif d['func']=='sig'
  play 'right'
  if $scene.class.ancestors.include?(Program) and d['appid']==$scene.class::AppID
    $scene.signaled(d['sender'], JSON.load(d['packet']))
    end
else
  Log.warning("Agent unknown data: #{d['func'].to_s}")
  play 'right'
                                      end
        end
  end
 $agentupst=0 if $agentupst==nil
 $agentupst+=1
 suc=true
 suc=false if $agentthr!=nil and ($agentthr.status!=false and $agentthr.status!=nil)
 if $agentupst>200 and suc==true
  $agentthr=Thread.new do
     $agentupst=0
  if $agent != nil
  x="\0"*4
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call($agent.pid,x)
if x[0..1] != "\003\001"
  Log.warning("Agent expected to be loaded")
                                        agent_start
$agentloaded = true
$agentfails=0 if $agentfails==nil
$agentfails+=1
$agentfaillasttime=0 if $agentfaillasttime==nil
eplay("right")
$agentfaillasttime=Time.now.to_i
  end
end
end
end
$activitytime||=Time.now.to_i
$activity||={}
$activity[$scene.class.name]||=0
$activity[$scene.class.name]+=1.0/Graphics.frame_rate
         register_activity if Time.now.to_i-$activitytime>3600 and $privacy_registeractivity==1
        Graphics.update
                              Input.update
      key_update
      keyprocs
      if $totray==true
        $totray=false
  Audio.bgs_stop
  run("bin\\elten_tray.bin")
  Win32API.new("user32","ShowWindow",'ii','i').call($wnd,0)
$trayreturn=true
        end
              if $stopmainthread == true
   if Thread::current == $subthreads.last or Thread::current == $mainthread
     l="main"
     l=$subthreads.size if Thread::current!=$mainthread
     Log.info("Pausing thread #{l}")
    Thread::stop
    Log.info("Thread resumed #{l}")
  end
  end
if tr == true
  $trayreturn=false
      $key=[0]*256
    $keyms=[0]*256
        delay(0.5)
        Win32API.new("user32", "ShowWindow", 'ii', 'i').call($wnd, 5)
        eplay("login")
  speak("ELTEN")
  end
if $agalarm==true and $alarmproc!=true
  $alarmproc=true
  eplay("dialog_open")
  alert(p_("EAPI_UI", "Alert!"))
    until escape or enter or space
      loop_update
    end
          $agalarm=false
      $agent.write(Marshal.dump({'func'=>'alarm_stop'}))
    eplay("dialog_close")
    loop_update
    $alarmproc=false
  end
  $activecontrols||=[]
  $lastactivecontrols||=[]
  for c in $lastactivecontrols
    c.blur if !$activecontrols.include?(c)
  end
  $lastactivecontrols=$activecontrols.dup
  $activecontrols.clear
  rescue Reset=>r
    if $reset==true
    $reset=false
    fail Reset
  end
rescue Hangup
  rescue Interrupt
  end
  
  def keys_copyvalues
    $nextkey=$key
    $nextkeyr=$keyr
    $nextkeypr=$keypr
    end

  # Creates a simple dialog with options yes and no and returns the user's decision
#
# @param text [String] a question to ask
# @return [Numeric] return 0 if user selected no or pressed escape, returns 1 if selected yes.
def confirm(text="")
  text.gsub!("jesteś pewien","jesteś pewna") if $language=="pl-PL" and Session.gender==0
  dialog_open  
  sel = menulr([_("No"),_("Yes")],true,0,text)
    loop do
        loop_update
        sel.update
        if escape
          loop_update
          dialog_close  
          return(0)
    end
        if enter
      loop_update
      dialog_close
      if sel.commandoptions.size==2      
        yield if sel.index==1 and block_given?
      return(sel.index)
    else
 if sel.index<=5
   return 0
 elsif sel.index <= 9
   yield
   return 1
 else
   return rand(2)
   end
      end
      end
if $keyr[0x10] and $keyr[84] and $keyr[78]
  sel = menulr(["Hmmmm, nie, podziękuję","Coś ty, oszalałeś?","Nie ma mowy","Nigdy w życiu","Pogięło cię? Jasne, że nie","Chyba masz jakieś zwidy jeśli sądzisz, że się zgodzę","W sumie, czemu nie","HMMM, kusi, pomyślmy, no ok, zgoda","Jasne, genialny pomysł","Jestem za","A ty zdecyduj"],true,0,"Możesz się szybciej decydować? "+text)
  end
      end
    end
    
    def prompt(header="",confirmation="Ok",cancellation=_("Cancel"))
      form=Form.new([Edit.new(header,"MULTILINE"),Button.new(confirmation),Button.new(cancellation)])
      snd=form.fields[1]
      dialog_open
      loop do
loop_update
if form.fields[0].text=="" and form.fields[1]!=nil
  form.fields[1]=nil
elsif form.fields[0].text!="" and form.fields[1]==nil
  form.fields[1]=snd
  end
        form.update
        if (((enter or space) and form.index==1) or (enter and $key[0x11] and form.index==0)) and form.fields[0].text_str!=""
          dialog_close
          return form.fields[0].text_str.gsub("\004LINE\004","\r\n")
          break
        end
        if ((enter or space) and form.index==2) or escape
          dialog_close
          return ""
          break
          end
        end
      end
    
    # Opens a waiting dialog
  def waiting
    f=""
    if FileTest.exist?("#{$soundthemepath}/BGS/waiting.ogg")
                      f="#{$soundthemepath}/BGS/waiting.ogg"
                    else
                      f="Audio/BGS/waiting.ogg"
                      end
          if $waitingvoice == nil
                          $waitingvoice = Bass::Sound.new(f, 1, true)
                          $waitingvoice.volume = $volume.to_f/150.0
                          $waitingvoice.play
                          end
                            $waitingopened = true
end

# Closes a waiting dialog
def waiting_end
    if $waitingvoice != nil
    for i in 1..10
      $waitingvoice.volume-=0.05
      delay(0.03)
      end
      $waitingvoice.close
    $waitingvoice = nil
    end
    $waitingopened = false
  end

      # Opens a dialog
  def dialog_open
            eplay("dialog_open")
        if FileTest.exist?("#{$soundthemepath}/BGS/dialog_background.ogg")
                          $dialogvoice ||= Bass::Sound.new("#{$soundthemepath}/BGS/dialog_background.ogg", 0, true)
                          $dialogvoice.volume=$volume.to_f/100.0
                          $dialogvoice.position=0
                                                    $dialogvoice.play
                          end
  $dialogopened = true
end

# Closes a dialog
def dialog_close
    if $dialogvoice != nil
    $dialogvoice.pause
  end
  eplay("dialog_close")
  NVDA.braille("") if NVDA.check
  $dialogopened=false
  end
  
                   

end
end