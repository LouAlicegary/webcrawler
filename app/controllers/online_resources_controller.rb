require 'nokogiri'
require 'open-uri'

class OnlineResourcesController < ApplicationController

  def index
    @all_resources = OnlineResource.all
  end

  def next_link_exists
    next_exists = false;
    @next_link = "";
    @navlinks_nodeset.each { |nav_node|
      if (nav_node.inner_text == "Next")
        next_exists = true;
        @next_link = @site_prefix + nav_node.attr('href')
        #puts nav_node
      end
    }
    next_exists 
  end #next_link_exists

  def update_last_completed
    current_website = Website.find(params[:id])
    the_time = Time.new
    current_website.last_completed = the_time
    current_website.save
    render json: the_time
  end 
   
  def resource_count 
    current_website = Website.find(params[:id])
    @resource_count = current_website.online_resources.count
    render json: @resource_count
  end #resource_count def


  ###################################################
  #
  #
  #   WEBSITE CRAWLING SCRIPTS ARE CONTAINED BELOW
  #
  #
  ###################################################


  def gutenberg
    
    # GET PARAMETERS COMING IN FROM AJAX CALL
    #current_website = Website.find(params[:id])
    current_count = params[:current_count]
    
    # PULL WEBSITE METADATA IN FROM A DATABASE
    #@site_query_url = current_website.query_url + current_count.to_s 
    #@site_prefix = current_website.site_prefix #'http://www.gutenberg.org'
    #@site_resource_xpath_string = current_website.resource_xpath #"//li[@class='booklink']" #gets NodeList of all books (25 at a time)
    ##@site_navlink_xpath_string = current_website.navigation_xpath #"span[@class='links']/a"
    #@resource_link_xpath_string = current_website.link_xpath #"a[@class='link']"
    #@resource_title_xpath_string = current_website.title_xpath #"span[@class='title']"
    #@resource_author_xpath_string = current_website.author_xpath #"span[@class='subtitle']"
    
    # MANUAL WEBSITE DATA FOR TESTING PURPOSES
    @site_query_url = 'http://www.bartleby.com/titles/'
    @site_prefix = ''
    @site_resource_xpath_string = "//table/tr/td/table/tr/td/a" #li[@class='catalog-result']"
    #@site_navlink_xpath_string = "span[@class='links']/a"
    @resource_link_xpath_string = "div[@class='download-btn']/a"
    @resource_title_xpath_string = "div[@class='result-data']/h3/a"
    @resource_author_xpath_string = "div/p[@class='book-author']/a"    
    
    # GENERATE THESE ON THE FLY FOR THE FIRST "PULLDOWN" OF RECORDS
    @doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    @booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)
    
    #@navlinks_nodeset = @doc.css(@site_navlink_xpath_string)  
    #next_link_exists #generates @next_link

    @error_messages = "" #Throws an error in the else block below if this isn't here
    
    
    puts "\n\n\n======\n @booklinks_nodeset.size \n @booklinks_nodeset \n======\n\n\n"
      
    
    
    # PARSE EACH "RESOURCE" WE'RE LOOKING FOR IN THE DOM TREE
    @booklinks_nodeset.each { |the_node|

      #puts "\n\n\n===================="
      #puts the_node
      #puts "====================\n\n\n"

      @link = @site_prefix + the_node.css(@resource_link_xpath_string).attr('href')
      @title = the_node.css(@resource_title_xpath_string).inner_text
      @author = the_node.css(@resource_author_xpath_string).inner_text

      user = OnlineResource.create(link: @link, title: @title, author: @author, website_id: params[:id])
      
      if user.valid?
        @error_messages += "Valid record<br>"
      else
        #@error_messages += "Invalid record<br>"
        user.errors.full_messages.each do |msg|
          @error_messages += msg + " "
        end
        @error_messages += "<br>"
      end
      
      current_count = current_count.to_i + 1
    }
    
    # THIS MIGHT NEED TO BE FIXED UP
    #@site_query_url = @next_link
    #@doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    #@booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)
    #@navlinks_nodeset = @doc.css(@site_navlink_xpath_string)
    
    render json: current_count.to_i    
  end


  def librivox
    # USES JS TO FETCH RECORDS SO I HAVENT MESSED WITH THIS YET
  end


  def bartleby
    
    # GET PARAMETERS COMING IN FROM AJAX CALL
    current_website = Website.find(params[:id])
    current_count = params[:current_count]
    
    # PULL WEBSITE METADATA IN FROM A DATABASE
    @site_query_url = current_website.query_url
    @site_prefix = current_website.site_prefix 
    @site_resource_xpath_string = current_website.resource_xpath 
    @resource_link_xpath_string = current_website.link_xpath 
    @resource_title_xpath_string = current_website.title_xpath 
    @resource_author_xpath_string = current_website.author_xpath    
       
    # GENERATE THESE ON THE FLY FOR THE FIRST "PULLDOWN" OF RECORDS
    @doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    @booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)
    
    # PARSE EACH "RESOURCE" WE'RE LOOKING FOR IN THE DOM TREE
    @booklinks_nodeset.each { |the_table_node|
      
      # THIS CAN PROBABLY BE FIXED TO TAKE A [] ARGUMENT
      if (the_table_node.element_children.length > 50)
        
        # PARSE EACH RESOURCE WE'RE LOOKING FOR IN THE DOM TREE
        the_table_node.element_children.each { |the_list_node|
          
          # SOME NODES ARE JUNK, SO SKIP THEM
          if (the_list_node.inner_text.length > 1)
            
            # GRAB ACTUAL DATA FOR EACH WORK
            @link = @site_prefix + the_list_node.css(@resource_link_xpath_string).attr('href')
            @title = the_list_node.css(@resource_title_xpath_string).inner_text
            @author = the_list_node.css(@resource_author_xpath_string).inner_text

            # CREATE DB RECORD AND UPDATE COUNTER
            OnlineResource.create(link: @link, title: @title, author: @author, website_id: params[:id]).valid?
            current_count = current_count.to_i + 1
                            
          end
        
        }
      
      end
    
    }
    
    response = {:status => "finished", :count => current_count.to_i}
    render json: response.to_json     
  
  end

  def poemhunter

    # GET PARAMETERS COMING IN FROM AJAX CALL
    current_website = Website.find(params[:id])
    current_count = params[:current_count]
    current_page = (current_count.to_i / 25) + 1
    current_page.to_i
    valid_count = 0
    
    # PULL WEBSITE METADATA IN FROM A DATABASE
    @site_query_url = current_website.query_url + current_page.to_s
    @site_prefix = current_website.site_prefix
    @site_resource_xpath_string = current_website.resource_xpath 
    @resource_link_xpath_string = current_website.link_xpath 
    @resource_title_xpath_string = current_website.title_xpath 
    @resource_author_xpath_string = current_website.author_xpath
       
    # GENERATE THESE ON THE FLY FOR THE FIRST "PULLDOWN" OF RECORDS
    @doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    @booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)
    
    # PARSE EACH "RESOURCE" WE'RE LOOKING FOR IN THE DOM TREE
    @booklinks_nodeset.each { |the_node|

      # GRAB ACTUAL DATA FOR EACH WORK
      @link = @site_prefix + the_node.css(@resource_link_xpath_string).attr('href')
      @title = the_node.css(@resource_title_xpath_string).inner_text
      @author = the_node.css(@resource_author_xpath_string).inner_text
      
      # CREATE DB RECORD AND UPDATE COUNTER
      if OnlineResource.create(link: @link, title: @title, author: @author, website_id: params[:id]).valid?
        valid_count = valid_count + 1
      end 
      current_count = current_count.to_i + 1 
           
    }
    
    if (valid_count > 0)
      @the_status = "in progress"
    else 
      @the_status = "finished"
    end
        
    response = {:status => @the_status, :count => current_count.to_i}
    render json: response.to_json 
    
  end

  def justinguitar

    # GET PARAMETERS COMING IN FROM AJAX CALL
    current_website = Website.find(params[:id])
    current_count = params[:current_count]
    
    # PULL WEBSITE METADATA IN FROM A DATABASE
    @site_query_url = current_website.query_url
    @site_prefix = current_website.site_prefix
    @site_resource_xpath_string = current_website.resource_xpath 
    @resource_link_xpath_string = current_website.link_xpath 
    @resource_title_xpath_string = current_website.title_xpath 
    @resource_author_xpath_string = current_website.author_xpath
       
    # GENERATE THESE ON THE FLY FOR THE FIRST "PULLDOWN" OF RECORDS
    @doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    @booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)
    
    # PARSE EACH "RESOURCE" WE'RE LOOKING FOR IN THE DOM TREE
    @booklinks_nodeset.each { |the_node|

      # IGNORES ALL LINKS THAT DON'T GO TO PHP FILES (E.G. HASHTAG TARGETS)
      if ( (the_node.attr('href') != nil) && (the_node.attr('href')[".php"] != nil) )

        # GRAB ACTUAL DATA FOR EACH WORK
        @link = @site_prefix + the_node.attr('href')
        @title = the_node.inner_text
        @author = "Justin Sandercoe" #the_node #.css(@resource_author_xpath_string).inner_text        
        
        # CREATE DB RECORD AND UPDATE COUNTER
        OnlineResource.create(link: @link, title: @title, author: @author, website_id: params[:id])
        current_count = current_count.to_i + 1 
           
      end     
    }
            
    response = {:status => "finished", :count => current_count.to_i}
    render json: response.to_json 
    
  end


  def wikibooks

    # GET PARAMETERS COMING IN FROM AJAX CALL
    current_website = Website.find(params[:id])
    current_count = params[:current_count]
    
    # PULL WEBSITE METADATA IN FROM A DATABASE
    @site_query_url = current_website.query_url
    @site_prefix = current_website.site_prefix
    @site_resource_xpath_string = current_website.resource_xpath 
    @resource_link_xpath_string = current_website.link_xpath 
    @resource_title_xpath_string = current_website.title_xpath 
    @resource_author_xpath_string = current_website.author_xpath
       
    # GENERATE THESE ON THE FLY FOR THE FIRST "PULLDOWN" OF RECORDS
    @doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    @booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)
    
    # PARSE EACH "RESOURCE" WE'RE LOOKING FOR IN THE DOM TREE
    @booklinks_nodeset.each { |the_node|
      
      # GRAB ACTUAL DATA FOR EACH WORK
      @link = @site_prefix + the_node.css(@resource_link_xpath_string).attr('href')
      @title = the_node.css(@resource_title_xpath_string).inner_text
      @author = " " 
      
      # CREATE DB RECORD AND UPDATE COUNTER 
      OnlineResource.create(link: @link, title: @title, author: @author, website_id: params[:id])
      current_count = current_count.to_i + 1 
              
    }
    
    # SEND BACK JSON RESPONSE        
    response = {:status => "finished", :count => current_count.to_i}
    render json: response.to_json 
    
  end

end