class WebsitesController < ApplicationController

  def index
    @all_websites = Website.all
  end
  
  def new
      
  end

  def create 
    @the_website = Website.new(passed_params)
    @the_website.save
    redirect_to @the_website # Shows the newly created record 
  end
  
  def show
    @the_website = Website.find(params[:id])
  end
  
  def edit
    @the_website = Website.find(params[:id])
  end

  def update
    @the_website = Website.find(params[:id])
    
    if @the_website.update(website_params) 
      redirect_to websites_path # Shows all records ( @the_website would show the newly updated record)
    else
      render 'edit'
    end
  end  
  
  private
  
  def passed_params
    #THIS NEEDS TO BE UPDATED WITH FIELDS FROM WEBSITES TABLE
    params.require(:the_object_name).permit(:name, :query_url, :site_prefix)
  end

  def website_params
    #THIS NEEDS TO BE UPDATED WITH FIELDS FROM WEBSITES TABLE
    params.require(:website).permit!
    #params.require(@the_website).permit(:name, :query_url, :site_prefix, :resource_xpath, :navigation_xpath, :link_xpath, :title_xpath, :author_xpath, :comments)
  end

end
