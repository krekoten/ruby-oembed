module OEmbed
  class Providers
    class << self
      @@urls = {}
      @@fallback = []

      def urls
        @@urls
      end

      def register(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            @@urls[url] = provider
          end
        end
      end

      def unregister(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            @@urls.delete(url)
          end
        end
      end

      def register_all
        register(Flickr, Viddler, Qik, Pownce, Revision3, Hulu, Vimeo, Embedly)
      end

      # Takes an array of OEmbed::Provider instances or OEmbed::ProviderDiscovery
      # Use this method to register fallback providers.
      # When the raw or get methods are called, if the URL doesn't match
      # any of the registerd url patters the fallback providers
      # will be called (in order) with the URL.
      #
      # A common example:
      #  OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery, OEmbed::Providers::OohEmbed)
      def register_fallback(*providers)
        @@fallback += providers
      end

      # Returns an array of all registerd fallback providers
      def fallback
        @@fallback
      end

      def find(url)
        @@urls[@@urls.keys.detect { |u| u =~ url }] || false
      end

      def raw(url, options = {})
        provider = find(url)
        if provider
          provider.raw(url, options)
        else
          fallback.each do |p|
            return p.raw(url, options) rescue OEmbed::Error
          end
          raise(OEmbed::NotFound)
        end
      end

      def get(url, options = {})
        provider = find(url)
        if provider
          provider.get(url, options)
        else
          fallback.each do |p|
            return p.get(url, options) rescue OEmbed::Error
          end
          raise(OEmbed::NotFound)
        end
      end
    end

    # Custom providers:
    Youtube = OEmbed::Provider.new("http://www.youtube.com/oembed/")
    Youtube << "http://*.youtube.com/*"

    Flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    Flickr << "http://*.flickr.com/*"

    Viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/")
    Viddler << "http://*.viddler.com/*"

    Qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")
    Qik << "http://qik.com/*"
    Qik << "http://qik.com/video/*"

    Revision3 = OEmbed::Provider.new("http://revision3.com/api/oembed/")
    Revision3 << "http://*.revision3.com/*"

    Hulu = OEmbed::Provider.new("http://www.hulu.com/api/oembed.{format}")
    Hulu << "http://www.hulu.com/watch/*"

    Vimeo = OEmbed::Provider.new("http://www.vimeo.com/api/oembed.{format}")
    Vimeo << "http://*.vimeo.com/*"
    Vimeo << "http://*.vimeo.com/groups/*/videos/*"

    Pownce = OEmbed::Provider.new("http://api.pownce.com/2.1/oembed.{format}")
    Pownce << "http://*.pownce.com/*"

    # A general end point, which then calls other APIs and returns OEmbed info
    OohEmbed = OEmbed::Provider.new("http://oohembed.com/oohembed/")
    OohEmbed << %r{http://yfrog.(com|ru|com.tr|it|fr|co.il|co.uk|com.pl|pl|eu|us)/(.*?)} # image & video hosting
    OohEmbed << "http://*.xkcd.com/*" # A hilarious stick figure comic
    OohEmbed << "http://*.wordpress.com/*/*/*/*" # Blogging Engine & community
    OohEmbed << "http://*.wikipedia.org/wiki/*" # Online encyclopedia
    OohEmbed << "http://*.twitpic.com/*" # Picture hosting for Twitter
    OohEmbed << "http://twitter.com/*/statuses/*" # Mirco-blogging network
    OohEmbed << "http://*.slideshare.net/*" # Share presentations online
    OohEmbed << "http://*.phodroid.com/*/*/*" # Photo host
    OohEmbed << "http://*.metacafe.com/watch/*" # Video host
    OohEmbed << "http://video.google.com/videoplay?*" # Video hosting
    OohEmbed << "http://*.funnyordie.com/videos/*" # Comedy video host
    OohEmbed << "http://*.thedailyshow.com/video/*" # Syndicated show
    OohEmbed << "http://*.collegehumor.com/video:*" # Comedic & original videos
    OohEmbed << %r{http://(.*?).amazon.(com|co.uk|de|ca|jp)/(.*?)/(gp/product|o/ASIN|obidos/ASIN|dp)/(.*?)} # Online product shopping
    OohEmbed << "http://*.5min.com/Video/*" # micro-video host

    PollEverywhere = OEmbed::Provider.new("http://www.polleverywhere.com/services/oembed/")
    PollEverywhere << "http://www.polleverywhere.com/polls/*"
    PollEverywhere << "http://www.polleverywhere.com/multiple_choice_polls/*"
    PollEverywhere << "http://www.polleverywhere.com/free_text_polls/*"

    MyOpera = OEmbed::Provider.new("http://my.opera.com/service/oembed", :json)
    MyOpera << "http://my.opera.com/*"

    ClearspringWidgets = OEmbed::Provider.new("http://widgets.clearspring.com/widget/v1/oembed/")
    ClearspringWidgets << "http://www.clearspring.com/widgets/*"

    NFBCanada = OEmbed::Provider.new("http://www.nfb.ca/remote/services/oembed/")
    NFBCanada << "http://*.nfb.ca/film/*"

    Scribd = OEmbed::Provider.new("http://www.scribd.com/services/oembed")
    Scribd << "http://*.scribd.com/*"

    MovieClips = OEmbed::Provider.new("http://movieclips.com/services/oembed/")
    MovieClips << "http://movieclips.com/watch/*/*/"

    TwentyThree = OEmbed::Provider.new("http://www.23hq.com/23/oembed")
    TwentyThree << "http://www.23hq.com/*"

    Embedly = OEmbed::Provider.new("http://api.embed.ly/v1/api/oembed")
    ["http://*youtube.com/watch*", "http://*.youtube.com/v/*", "http://youtu.be/*",
      "http://www.veoh.com/*/watch/*", "http://*justin.tv/*", "http://*justin.tv/*/b/*",
      "http://www.ustream.tv/recorded/*", "http://www.ustream.tv/channel/*", "http://qik.com/video/*",
      "http://qik.com/*", "http://*revision3.com/*", "http://*.dailymotion.com/video/*",
      "http://*.dailymotion.com/*/video/*", "http://www.collegehumor.com/video:*",
      "http://*twitvid.com/*", "http://www.break.com/*/*", "http://vids.myspace.com/index.cfm?fuseaction=vids.individual&videoid*",
      "http://www.myspace.com/index.cfm?fuseaction=*&videoid*", "http://www.metacafe.com/watch/*", "http://blip.tv/file/*",
      "http://*.blip.tv/file/*", "http://video.google.com/videoplay?*", "http://*revver.com/video/*",
      "http://video.yahoo.com/watch/*/*", "http://video.yahoo.com/network/*", "http://*viddler.com/explore/*/videos/*",
      "http://liveleak.com/view?*", "http://www.liveleak.com/view?*", "http://animoto.com/play/*", "http://dotsub.com/view/*",
      "http://www.overstream.net/view.php?oid=*", "http://*yfrog.*/*", "http://tweetphoto.com/*", "http://www.flickr.com/photos/*",
      "http://*twitpic.com/*", "http://*imgur.com/*", "http://*.posterous.com/*", "http://post.ly/*", "http://twitgoo.com/*",
      "http://i*.photobucket.com/albums/*", "http://gi*.photobucket.com/groups/*", "http://phodroid.com/*/*/*",
      "http://www.mobypicture.com/user/*/view/*", "http://moby.to/*", "http://xkcd.com/*", "http://www.asofterworld.com/index.php?id=*",
      "http://www.qwantz.com/index.php?comic=*", "http://23hq.com/*/photo/*", "http://www.23hq.com/*/photo/*",
      "http://*dribbble.com/shots/*", "http://drbl.in/*", "http://*.smugmug.com/*", "http://*.smugmug.com/*#*",
      "http://emberapp.com/*/images/*", "http://emberapp.com/*/images/*/sizes/*", "http://emberapp.com/*/collections/*/*",
      "http://emberapp.com/*/categories/*/*/*", "http://embr.it/*", "http://www.whitehouse.gov/photos-and-video/video/*",
      "http://www.whitehouse.gov/video/*", "http://wh.gov/photos-and-video/video/*", "http://wh.gov/video/*", "http://www.hulu.com/watch*",
      "http://www.hulu.com/w/*", "http://hulu.com/watch*", "http://hulu.com/w/*", "http://movieclips.com/watch/*/*/",
      "http://movieclips.com/watch/*/*/*/*", "http://*crackle.com/c/*", "http://www.fancast.com/*/videos", "http://www.funnyordie.com/videos/*",
      "http://www.vimeo.com/groups/*/videos/*", "http://www.vimeo.com/*", "http://vimeo.com/groups/*/videos/*", "http://vimeo.com/*",
      "http://www.ted.com/talks/*.html*", "http://www.ted.com/talks/lang/*/*.html*", "http://www.ted.com/index.php/talks/*.html*",
      "http://www.ted.com/index.php/talks/lang/*/*.html*", "http://*omnisio.com/*", "http://*nfb.ca/film/*", "http://www.thedailyshow.com/watch/*",
      "http://www.thedailyshow.com/full-episodes/*", "http://www.thedailyshow.com/collection/*/*/*", "http://movies.yahoo.com/movie/*/video/*",
      "http://movies.yahoo.com/movie/*/info", "http://movies.yahoo.com/movie/*/trailer", "http://www.colbertnation.com/the-colbert-report-collections/*",
      "http://www.colbertnation.com/full-episodes/*", "http://www.colbertnation.com/the-colbert-report-videos/*", "http://www.comedycentral.com/videos/index.jhtml?*",
      "http://www.theonion.com/video/*", "http://theonion.com/video/*", "http://wordpress.tv/*/*/*/*/", "http://www.traileraddict.com/trailer/*",
      "http://www.traileraddict.com/clip/*", "http://www.traileraddict.com/poster/*", "http://www.escapistmagazine.com/videos/*",
      "http://www.trailerspy.com/trailer/*/*", "http://www.trailerspy.com/trailer/*", "http://www.trailerspy.com/view_video.php*",
      "http://soundcloud.com/*", "http://soundcloud.com/*/*", "http://soundcloud.com/*/sets/*", "http://soundcloud.com/groups/*", "http://www.lala.com/#album/*",
      "http://www.lala.com/album/*", "http://www.lala.com/#song/*", "http://www.lala.com/song/*", "http://www.mixcloud.com/*/*/", "http://*amazon.*/gp/product/*",
      "http://*amazon.*/*/dp/*", "http://*amazon.*/dp/*", "http://*amazon.*/o/ASIN/*", "http://*amazon.*/gp/offer-listing/*", "http://*amazon.*/*/ASIN/*",
      "http://*amazon.*/gp/product/images/*", "http://www.amzn.com/*", "http://amzn.com/*", "http://twitter.com/*/status/*", "http://twitter.com/*/statuses/*",
      "http://www.slideshare.net/*/*", "http://*.scribd.com/doc/*", "http://screenr.com/*", "http://www.5min.com/Video/*", "http://www.howcast.com/videos/*",
      "http://www.screencast.com/*/media/*", "http://screencast.com/*/media/*", "http://www.screencast.com/t/*", "http://screencast.com/t/*",
      "http://www.clearspring.com/widgets/*", "http://my.opera.com/*/albums/show.dml?id=*", "http://my.opera.com/*/albums/showpic.dml?album=*&picture=*",
      "http://tumblr.com/*", "http://*.tumblr.com/post/*"].each do |url|
      
      Embedly << url
    end
  end
end
