require 'nokogiri' # NOTE(dbp): may require gem install nokogiri

class AssignmentController < ApplicationController

  def get_assignment
    assignment = Assignment.find_by(:uid => params[:uid])
    if assignment.nil?
      render :json => {:code => 404,
        :message => "No such assignment"}, :status => 404
    else
      if !authenticated?
        @html = "Not logged in"
      else
        scribbled = Scribble::render(assignment.path_ref)
        doc = Nokogiri::HTML(scribbled)
        main = doc.css('div.main').first
        if main.nil?
          # NOTE(dbp): a scribble doc without a main div is bad.
          raise Scribble::ScribbleError, scribbled
        end
        
        main.css("[data-ct-node='1']").each do |node|
          if node["data-resources"]
            resources = JSON.parse(node["data-resources"])
            resources.keys.each do |k|
              # add user credentials
              resources[k] = resources[k] + ":" + current_user.id.to_s
              # NOTE(dbp): encrypt here
            end
            node["data-resources"] = resources.to_json
          end
        end
        
        @html = main.to_html
      end
    end
  end
  
end
