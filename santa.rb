require 'rubygems'
require 'sinatra'
require 'mongo'
require 'uri'

include Mongo

DB = Connection.new(ENV['DATABASE_URL'] || 'localhost').db('santa')
if ENV['DATABASE_USER'] && ENV['DATABASE_PASSWORD']
  auth = DB.authenticate(ENV['DATABASE_USER'], ENV['DATABASE_PASSWORD'])
end

configure :production do
  enable :raise_errors
end

get '/init' do
  init_tree
  redirect '/'
end

get '/' do
  @gifts = DB['gifts'].find().sort("opened_at", :asc)
  erb :index
end

get '/add_gift' do
  erb :add_gift
end

post '/add_gift' do
  DB['gifts'].insert({:gift_id => params[:gift_id],
                      :key => params[:key],
                      :location => params[:location],
                      :info => {
                        :title => params[:info_title],
                        :link => params[:info_link],
                        :message => params[:info_message],
                        :icon => params[:info_icon]},
                      :receiver => {
                        :name => params[:receiver_name],
                        :icon => params[:receiver_icon]}
                      })
  redirect '/'
end

post '/open-gift' do
  if verify_key(params[:gift], params[:key])
    # gift can be open
    open_time = Time.now
    open_gift(params[:gift], open_time)
  end
  redirect "/#{params[:location]}"
end

get '/:location' do
  @gifts = DB['gifts'].find(:location => params[:location]).sort("opened_at", :asc)
  erb :index
end

helpers do
  
  def init_tree
    DB['gifts'].drop
    gifts = [
      # girard
      {:gift_id => 1, :key => "6790", :location => "girard",
        :info => {:title => "Serge Gainsbourg - L'Intégrale", :link => "http://torrents.thepiratebay.org/3571000/Serge_Gainsbourg.3571000.TPB.torrent", :message => "Max m'a dit que vous aviez bien aimé ré-entendre Gainsbourg pendant votre passage à toulouse, alors voici son intégrale :) Joyeux Noël, Alex", :icon => "images/gifts/gainsbourg.png"},
        :receiver => {:name => "Papa et maman", :icon => "images/receiver/alain.png", :message => ""}},
        
      {:gift_id => 2, :key => "3498", :location => "girard",
        :info => {:title => "NOVA - La Boite Noire", :link => "http://www.seedpeer.com/download/la_boite_noire_25_ans_de_nova_ii_25_ans_avant_nova_1956_gt_1980_coffret_25_cd_mp3_192_kbps/4c0defdf46dda461b174592230af622db5484f84", :message => "Salut Muriel, je l'offre à tout le monde ce coffret à Noël tellement c'est la meilleure compilation que j'ai pu écouter cette année, bonne redécouverte ;) Joyeux Noël, Alex", :icon => "/images/gifts/nova.png"},
        :receiver => {:name => "Muriel", :icon => "images/receiver/muriel.png", :message => "images/gifts/nova.png"}},
        
      {:gift_id => 3, :key => "1092", :location => "girard",
        :info => {:title => "Batman - Gotham Night", :link => "http://torrents.thepiratebay.org/4272784/Batman-Gotham.Knight%5B2008%5DDvDrip-aXXo.4272784.TPB.torrent", :message => "Salut Florent, ok Batman... un peu enfantin tu me diras, mais celui là est spécial, pour les fans d'animations, avec un caractère mature dans le personnage. Bon visionnage :) Joyeux Noël, Alex", :icon => "/images/gifts/batman.png"},
        :receiver => {:name => "Florent", :icon => "images/receiver/florent.png", :message => "images/gifts/batman.png"}},

      {:gift_id => 4, :key => "4329", :location => "girard",
        :info => {:title => "Man on Wire", :link => "http://torrents.thepiratebay.org/4491765/Man.On.Wire.DOCU.DVDSCR.XVID-iFN.4491765.TPB.torrent", :message => "Un des meilleur documentaire de l'année, j'espère que vous ne l'avez pas encore vu avec Florent, sinon demandes en moi un autre ;) Joyeux Noël, Alex", :icon => "images/gifts/manonwire.png"},
        :receiver => {:name => "Sandra", :icon => "images/receiver/sandra.png", :message => ""}},

      {:gift_id => 5, :key => "0128", :location => "girard",
        :info => {:title => "Shaun the Sheep - Back in the Baath", :link => "http://torrents.thepiratebay.org/4729922/Shaun.The.Sheep.Back.In.The.Baath.2009.COMPLETE.NTSC.DVDR-INSECT.4729922.TPB.torrent", :message => "Salut Youri, pour tes prochains mois de videos sur l'ordinateur, une superbe animation anglaise pour les enfants, je suis sûr que tes parents continuerons à regarder en cachette tellement c'est bien fait :) Joyeux Noël, Alex", :icon => "/images/gifts/shaun.png"},
        :receiver => {:name => "Youri", :icon => "images/receiver/youri.png", :message => ""}},

      {:gift_id => 6, :key => "1234", :location => "girard",
        :info => {:title => "Bomb It!", :link => "http://www.vertor.com/index.php?mod=download&id=88328", :message => "Je l'ai pas encore vu, mais ça à l'air d'être un superbe documentaire sur la culture du streetart! Joyeux Noël, Alex", :icon => "images/gifts/bombit.png"},
        :receiver => {:name => "Swann", :icon => "images/receiver/swann.png", :message => ""}},

      {:gift_id => 7, :key => "0932", :location => "girard",
        :info => {:title => "Antifa - Chasseur de Skins", :link => "http://www.vertor.com/index.php?mod=download&id=50578", :message => "Excellent documentaire sur l'histoire des années 80 en France, il s'y est passé un combat, et le fascisme a reculé. Bonne musique, bons souvenirs. Joyeux Noël, Alex", :icon => "images/gifts/antifa.png"},
        :receiver => {:name => "Olivier", :icon => "images/receiver/olivier.png", :message => ""}},

        # toulouse:
      {:gift_id => 20, :key => "5467", :location => "toulouse",
        :info => {:title => "Sur les Pavés - Réponse à Antifa", :link => "http://dl.btjunkie.org/torrent/SUR-LES-PAVES-R-eacute-ponse-agrave-Antifa-2009-french/4358ee3f49e813caac85aa2319dbb1a8802f0bab20c0/download.torrent", :message => "Excellent! un document réalisé par les skins de l'époque d'antifa, en démentis du premier documentaire et quelques pièces en plus. Joyeux Noël, Alex", :icon => "images/gifts/surlespaves.png"},
        :receiver => {:name => "Max", :icon => "images/receiver/maxence.png", :message => ""}},

      {:gift_id => 21, :key => "3696", :location => "toulouse",
        :info => {:title => "Beltesassar's Short Animation Festival - Compil 14", :link => "http://torrents.thepiratebay.org/4510602/Beltesassar__s_Short_Animation_Festival_14.4510602.TPB.torrent", :message => "On a commencé a regarder une des 15 compilations qui existent, fantastique selection d'un professeur Hollandais, Mr Beltesassar, en haute qualité. Tu cherchera surement les 14 autres DVD ensuite :) Joyeux Noël, Alex", :icon => "images/gifts/Beltesassar-1.png"},
        :receiver => {:name => "Julie", :icon => "images/receiver/julie.png", :message => "images/gifts/Beltesassar-1.png"}},

      {:gift_id => 22, :key => "0843", :location => "toulouse",
        :info => {:title => "Beltesassar's Short Animation Festival - Compil 13", :link => "http://torrents.thepiratebay.org/4143506/Beltesassar__s_Short_Animation_Festival_Part_13.4143506.TPB.torrent", :message => "Découvert il y a quelques jours, une selection fantstique de films d'animations par un professeur hollandais, Mr Beltesassar, il y a 14 autres volumes si t'adores :D Joyeux Noël, Alex", :icon => "images/gifts/Beltesassar-2.png"},
        :receiver => {:name => "Joan", :icon => "images/receiver/joan.png", :message => ""}},

      {:gift_id => 23, :key => "1231", :location => "toulouse",
        :info => {:title => "Beltesassar's Short Animation Festival - Compil 12", :link => "http://torrents.thepiratebay.org/4075199/Beltesassar__s_Short_Animation_Festival_Part_12.4075199.TPB.torrent", :message => "Découvert il y a quelques jours, une selection fantstique de films d'animations par un professeur hollandais, Mr Beltesassar, il y a 14 autres volumes si t'adores :D Joyeux Noël, Alex", :icon => "images/gifts/Beltesassar-3.png"},
        :receiver => {:name => "Sophie", :icon => "images/receiver/sophie.png", :message => ""}},

      {:gift_id => 27, :key => "5664", :location => "toulouse",
        :info => {:title => "Beltesassar's Short Animation Festival - Compil 15", :link => "http://torrents.thepiratebay.org/4771050/Beltesassar_Short_Animation_Festival_Part_15.4771050.TPB.torrent", :message => "Découvert il y a quelques jours, une selection fantstique de films d'animations par un professeur hollandais, Mr Beltesassar, il y a 14 autres volumes si vous adorez ou si Milo accroche :D Joyeux Noël, Alex", :icon => "images/gifts/Beltesassar-4.png"},
        :receiver => {:name => "Séb & Xav & Milo", :icon => "/images/receiver/seb.png", :message => ""}},

      # berlin
      {:gift_id => 60, :key => "1241", :location => "berlin",
        :info => {:title => "NOVA - La Boite Noire", :link => "http://www.seedpeer.com/download/la_boite_noire_25_ans_de_nova_ii_25_ans_avant_nova_1956_gt_1980_coffret_25_cd_mp3_192_kbps/4c0defdf46dda461b174592230af622db5484f84", :message => "25 years of great music! Build up by Nova, a famous french radio, it's the most inspiring stuff I've listened during the year, I so hoped I could have discovered it earlier :) Joyeux Noël, Alex", :icon => "images/gifts/nova.png"},
        :receiver => {:name => "Christine", :icon => "images/receiver/christine.png", :message => ""}},

      {:gift_id => 61, :key => "6711", :location => "berlin",
        :info => {:title => "FPGA MD5 cracker", :link => "http://nsa.unaligned.org/", :message => "If you can play with FPGA, please make a toy like this someday :D Joyeux Noël, Alex", :icon => "/images/gifts/nsa.png"},
        :receiver => {:name => "Joseph", :icon => "images/receiver/joseph.png", :message => "images/gifts/nsa.png"}},

      {:gift_id => 62, :key => "6346", :location => "berlin",
        :info => {:title => "The King of Kong", :link => "http://torrents.thepiratebay.org/4670384/The.King.of.Kong.2007.LIMITED.Documentary.DVDRip.XviD-SeRbOvItCh.4670384.TPB.torrent", :message => "I hope you havn't seen it yet, a great tale of video game history! Joyeux Noël, Alex", :icon => "/images/gifts/king_of_kong.png"},
        :receiver => {:name => "berliners", :icon => "images/receiver/berliners.png", :message => "images/gifts/king_of_kong.png"}},

      # madrid:
      {:gift_id => 80, :key => "1209", :location => "madrid",
        :info => {:title => "NOVA - La Boite Noire", :link => "http://www.seedpeer.com/download/la_boite_noire_25_ans_de_nova_ii_25_ans_avant_nova_1956_gt_1980_coffret_25_cd_mp3_192_kbps/4c0defdf46dda461b174592230af622db5484f84", :message => "25 años de musica genial! Fabricado por una radio muy famosa en Francia, es una de las cosas que me ha el mas inspirado durante 2009, bisous :) Joyeux Noël, Alex", :icon => "/images/gifts/nova.png"},
        :receiver => {:name => "Mercedes", :icon => "images/receiver/mercedes.png", :message => "images/gifts/nova.png"}},

      {:gift_id => 81, :key => "4937", :location => "madrid",
        :info => {:title => "Make Magazine", :link => "http://thepiratebay.org/torrent/4995567/MAKE_Magazine_2006-2009_%5B01-18%5D", :message => "La coleccion integral de los papeles de Make, espero que funccionara bien en tu ebook :) Joyeux Noël, Alex", :icon => "/images/gifts/make.png"},
        :receiver => {:name => "Maki", :icon => "images/receiver/maki.png", :message => ""}}
    ]
    
    DB['gifts'].insert(gifts)
    DB['gifts'].create_index("gift_id")
  end
  
  def verify_key(gift_id, key)
    DB['gifts'].find_one("gift_id" => gift_id.to_i)["key"] == key
  end
  
  def open_gift(gift_id, timestamp)
    DB['gifts'].update({"gift_id" => gift_id.to_i}, {"$set" => {"opened_at" => timestamp}})
  end
  
end
