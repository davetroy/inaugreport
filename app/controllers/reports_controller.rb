class ReportsController < ApplicationController
  protect_from_forgery :except => [:create]
  before_filter :filter_from_params, :only => [ :index, :reload, :map, :chart, :stats ]
  before_filter :login_required, :except => [:create, :index, :show, :chart, :stats, :map, :reload]
  caches_page [:index, :show], :if => proc{|controller| (!controller.request.parameters["format"].blank? && controller.request.parameters["format"] != "html") && controller.request.env["QUERY_STRING"].blank?}
  
  # GET /reports
  def index
    respond_to do |format|
      format.html do
        @live_feed = (params[:live] == "1")
        if !@live_feed 
          @reports = Report.find_with_filters(@filters)
        end
      end      
      format.kml do
        @reports = Report.with_location.find_with_filters(@filters)
        case params[:live]
        when /1/
          render :template => "reports/reports.kml.builder"
        else
          render :template => "reports/index.kml.builder"
        end
      end
      format.json do 
        logger.info "Testing"
        @reports = Report.with_location.find_with_filters(@filters)
        logger.info "Reports: #{@reports.length}"
        render :json => @reports.to_json, :callback => params[:callback]
      end      
      format.atom do
        @reports = Report.with_location.find_with_filters(@filters)
      end
    end
  end
  
  # GET /reports/reload (AJAX)
  def reload
    @filters[:per_page] = params[:per_page] || 50
    @reports = Report.find_with_filters(@filters)
    render :partial => @reports
  end

  # GET /reports/review
  def review
    # fetches basic review layout
    @reports = Report.assigned(current_user)
    render :layout => "admin"
  end
  
  # POST /reports/assign
  def assign
    # assigns a set of reviews to the user
    # FIXME: causes 10 updates when one would suffice
    @reports = Report.unassigned.assign(current_user)
    respond_to do |format|
      format.js { 
        render :update do |page|
          page['reports'].replace_html :partial => 'reviews', :locals => { :reports => @reports }
          page['reports'].show
        end
      }
    end
  end
  
  # POST /reports/release
  def release
    # could we do this with named_scope extensions? kinda gnarly...
    # Report.assigned(current_user).release
    Report.update_all("reviewer_id = NULL, assigned_at = NULL", [ 'reviewer_id = ? AND reviewed_at IS NULL', current_user.id])
    respond_to do |format|
      format.js {
        render :update do |page|
          page['reports'].fade
        end
      }
    end
  end
  
  # GET /reports/:id
  def show 
    @report = Report.find(params[:id])
    respond_to do |format|
      format.html {
        render :partial => "report"
      }
      format.js {
        render :update do |page|
          page["report_#{@report.id}"].replace :partial => 'report_review', :locals => { :report => @report }
        end
      }
    end
  end
    
  # GET /reports/:id/edit
  def edit
    @report = Report.find(params[:id])
    respond_to do |format|
      format.js {
        render :update do |page|
          page["report_#{@report.id}"].replace :partial => 'edit', :locals => { :report => @report }
        end
      }
    end
  end
  
  # POST /reports/:id
  def update
    @report = Report.find(params[:id])
    @report.location = Location.geocode(params[:location])
    @report.text += " trans: #{params[:transcription]}" if params[:transcription]
    
    if @report.update_attributes(params[:report])
      respond_to do |format|
        format.xml { head :ok }
        format.js {
          render :update do |page|
            page["report_#{@report.id}"].replace :partial => 'report_review', :locals => { :report => @report }
            page["report_#{@report.id}"].visual_effect :highlight
          end
        }
      end
    else
      respond_to do |format|
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
        format.js {
          render :update do |page|
            page["error_report_#{@report.id}"].replace(
              error_messages_for(:report, :id => "error_report_#{@report.id}", :class => 'xhr_errors', :header_message => nil, :message => nil)
            ).show
          end
        }
      end
    end
  end
  
  # POST /reports/:id/confirm
  def confirm
    @report = Report.find(params[:id])
    if @report.confirm!(current_user)
      respond_to do |format|
        format.xml { head :ok }
        format.js {
          render :update do |page|
            page["report_#{@report.id}"].fade( :duration => 0.3 )
          end
        }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @report.errors, :status => :unprocessable_entity }
        format.js {
          render :update do |page|
            page["error_report_#{@report.id}"].replace(
              error_messages_for(:report, :id => "error_report_#{@report.id}", :class => 'xhr_errors', :header_message => nil, :message => nil)
            ).show
          end
        }
      end
    end
  end
  
  # POST /reports/:id/dismiss
  def dismiss
    @report = Report.find(params[:id])
    @report.update_attributes!(params[:report])
    @report.dismiss!(current_user)
    respond_to do |format|
      format.xml { head :ok }
      format.js {
        render :update do |page|
          page["report_#{@report.id}"].fade( :duration => 0.3 )
        end
      }
    end
  rescue ActiveRecord::InvalidRecord => e
    respond_to do |format|
      format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
    end
  end
  
  def stats
    @hourly_usage = Report.hourly_usage
    @number_reports = Report.count
    @election_reports = Report.count(:all, :conditions => ["created_at > '2008-11-04'"])
  end
  
  def map  
    render  :layout => "embed"
  end
  
  def chart 
    @reports = Report.with_wait_time.find_with_filters(@filters)     
  end
  
  # POST /reports
  # Used by iPhone & Android app; could be used for other APIs
  def create
    respond_to do |format|
      format.iphone do
        result = IphoneReporter.save_report(params)
        render :text => result and return true
      end
      format.android do
        result = AndroidReporter.save_report(params)
        render :text => result and return true
      end
    end
  end
  
end
