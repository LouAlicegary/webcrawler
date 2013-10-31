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



  def gutenberg
    
  end


  def librivox
    
  end


  def bartleby
    
    # GET PARAMETERS COMING IN FROM AJAX CALL
    current_website = Website.find(params[:id])
    #current_count = params[:current_count]
    
    # PULL WEBSITE METADATA IN FROM A DATABASE
    @site_query_url = current_website.query_url
    @site_prefix = current_website.site_prefix #'http://www.gutenberg.org'
    @site_resource_xpath_string = current_website.resource_xpath #"//li[@class='booklink']" #gets NodeList of all books (25 at a time)
    @resource_link_xpath_string = current_website.link_xpath #"a[@class='link']"
    @resource_title_xpath_string = current_website.title_xpath #"span[@class='title']"
    @resource_author_xpath_string = current_website.author_xpath #"span[@class='subtitle']"    
    
    
    # MANUAL WEBSITE DATA FOR TESTING PURPOSES
    #@site_query_url = 'http://www.bartleby.com/titles/'
    #@site_prefix = 'http://www.bartleby.com'
    #@site_resource_xpath_string = "//table/tr/td/table" #li[@class='catalog-result']"
    #@resource_link_xpath_string = "a[1]"
    #@resource_title_xpath_string = "a[1]"
    #@resource_author_xpath_string = "a[2]"    
    
    # GENERATE THESE ON THE FLY FOR THE FIRST "PULLDOWN" OF RECORDS
    @doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    @booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)
    
    current_count = 0  
    
    # PARSE EACH "RESOURCE" WE'RE LOOKING FOR IN THE DOM TREE
    @booklinks_nodeset.each { |the_table_node|
      if (the_table_node.element_children.length > 50)
        the_table_node.element_children.each { |the_list_node|
          if (the_list_node.inner_text.length > 1)
            @link = @site_prefix + the_list_node.css(@resource_link_xpath_string).attr('href')
            @title = the_list_node.css(@resource_title_xpath_string).inner_text
            @author = the_list_node.css(@resource_author_xpath_string).inner_text

            if OnlineResource.create(link: @link, title: @title, author: @author, website_id: params[:id]).valid?
              current_count = current_count.to_i + 1
            end            
                 
          end
        }
      end
    }
    
    response = {:status => "finished", :count => current_count.to_i}
    render json: response.to_json     
  end




  def welcome
    
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
    
    
    puts "\n\n\n===================="
    puts @booklinks_nodeset.size
    puts @booklinks_nodeset
    puts "====================\n\n\n"
      
    
    
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
    
  end #welcome def   
   
   
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
end