#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_SoundThemes
  def main(canceled=false)
    @return = false
st=Dir.entries($soundthemesdata)
st.delete("..")
st.delete(".")
@soundthemes = []
for s in st
      d=$soundthemesdata+"\\"+s
      if File.directory?(d) and FileTest.exists?(d+"\\__name.txt")
        t=Struct_SoundThemes_SoundTheme.new(s, readfile(d+"\\__name.txt"))
        @soundthemes.push(t)
        end
      end
  if @soundthemes.size==0
    alert(p_("SoundThemes", "No sound themes."))
    if canceled == false
    stdownload
  else
    $scene = Scene_Main.new
    end
return
  end
    @soundthemes.push(Struct_SoundThemes_SoundTheme.new("", p_("SoundThemes", "default")))
  loop_update
    @selt = @soundthemes.map{|s| s.name}
  @selt.push(p_("SoundThemes", "Download sound themes"))
  @sel = Select.new(@selt,true,0,p_("SoundThemes", "Sound themes"))
  @sel.bind_context{|menu|context(menu)}
  loop do
loop_update
    @sel.update
    update
    break if $scene != self or @return == true
          end
  end
  def update
    $scene = Scene_Main.new if escape
    if enter
            if @sel.index < @soundthemes.size
                            seltheme(@soundthemes[@sel.index])
              else
            stdownload
            @return = true
            return
          end
        end
        end
        def context(menu)
          menu.option(p_("SoundThemes", "Select")) {
                      if @sel.index<@soundthemes.size
              seltheme(@soundthemes[@sel.index])
            else
              stdownload
              @return=true
            end
          }
          menu.option(p_("SoundThemes", "New")) {
                        $scene=Scene_Sounds.new("")
          }
          if @sel.index<@soundthemes.size-1
          menu.option(p_("SoundThemes", "Edit")) {
                        $scene=Scene_Sounds.new(@soundthemes[@sel.index].path)
          }
          menu.option(p_("SoundThemes", "Delete")) {
                          confirm(p_("SoundThemes", "Are you sure you want to delete this soundtheme?")) {
                deldir($soundthemesdata+"\\"+@soundthemes[@sel.index].path)
                @return=true
                main
                }
          }
          end
          end
    def seltheme(theme)
      confirm(p_("SoundThemes", "Do you wish to use this sound theme?")) {
              if theme.path!=""
                                                $soundthemepath = $soundthemesdata + "\\" + theme.path
                                  else
              $soundthemepath=""                    
      end
                                   writeconfig("Interface", "SoundTheme", theme.path)
                alert(_("Saved"))
                          $soundthemespath = theme.path
                          return true
                          }
                          return false
end
    def stdownload
      sttemp = srvproc("soundthemes",{"type"=>"1"})
            err = sttemp[0].to_i
      if err < 0
        alert(_("Error"))
        $scene = Scene_Main.new
        return
      end
      @std=[]
      for i in 0...sttemp.size/2
        @std.push(Struct_SoundThemes_SoundTheme.new(sttemp[i*2+1].delete("\r\n"), sttemp[i*2+2].delete("\r\n")))
      end
         @sel = Select.new(@std.map{|s| s.name},true,0,p_("Soundthemes", "Select theme to download"))
  loop do
   loop_update
   @sel.update
   if escape
          main(canceled=true)
     return
   end
   if enter
          downloadtheme(@std[@sel.index].path)
     return
     end
   end
 end
 def downloadtheme(path)
     Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode($soundthemesdata + "\\" + path), nil)
    Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode($soundthemesdata + "\\" + path + "\\BGS"), nil)
    Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode($soundthemesdata + "\\" + path + "\\SE"), nil)
    st=srvproc("soundthemes",{"listfiles"=>path})
    waiting
    for s in st[1..-1]
      s=s.delete!("\r\n").gsub("../","").gsub("..\\","")
            downloadfile($url+"/soundthemes/"+s, $soundthemesdata+"/"+s,nil,nil,true)
                      end
         waiting_end
  alert(_("Saved"))
  main
  return
   end
 end
 
 class Struct_SoundThemes_SoundTheme
   attr_accessor :path, :name
   def initialize(path=nil, name=nil)
     @path, @name = path, name
     end
   end