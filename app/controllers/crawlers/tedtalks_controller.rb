require 'nokogiri'
require 'open-uri'

class Crawlers::TedtalksController < OnlineResourcesController

  def crawl

    # GET PARAMETERS COMING IN FROM AJAX CALL
    current_website = Website.find(params[:id])
    current_count = params[:current_count]
    valid_count = 0
    
    # PULL WEBSITE METADATA IN FROM A DATABASE
    @site_query_url = current_website.query_url + current_count
    @site_prefix = current_website.site_prefix
    @site_resource_xpath_string = current_website.resource_xpath 
    @resource_link_xpath_string = current_website.link_xpath 
    @resource_title_xpath_string = current_website.title_xpath 
    @resource_author_xpath_string = current_website.author_xpath
       
    # GENERATE THESE ON THE FLY FOR THE FIRST "PULLDOWN" OF RECORDS
    @doc = Nokogiri::HTML(open(@site_query_url)).css('body')
    @booklinks_nodeset = @doc.xpath(@site_resource_xpath_string)

    #puts "\n\n\n======\n #{@booklinks_nodeset.size} \n #{@booklinks_nodeset} \n======\n\n\n"

    # PARSE EACH "RESOURCE" WE'RE LOOKING FOR IN THE DOM TREE
    @booklinks_nodeset.each { |the_node|

      # GRAB ACTUAL DATA FOR EACH WORK
      @link = @site_prefix + the_node.css(@resource_link_xpath_string).attr('href')
      @title = the_node.css(@resource_title_xpath_string).inner_text
      if (@title.include? ":")
        @author = the_node.css(@resource_title_xpath_string).inner_text[0,@title.index(':')]
      else
        @author = ""
      end
       
      # CREATE DB RECORD AND UPDATE COUNTER
      if OnlineResource.create(link: @link, title: @title, author: @author, website_id: params[:id]).valid?
        valid_count = valid_count + 1
      end 
      current_count = current_count.to_i + 1        
    }
    
    # SEND BACK JSON RESPONSE
    if (valid_count > 0)
      @the_status = "in progress"
    else 
      @the_status = "finished"
    end
    response = {:status => @the_status, :count => current_count.to_i}
    render json: response.to_json 
    
  end

end