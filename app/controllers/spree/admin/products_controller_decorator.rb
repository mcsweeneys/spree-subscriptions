Spree::Admin::ProductsController.class_eval do
  def show
    session[:return_to] ||= request.referer
    respond_to do |format|
      format.csv { render text: Spree::Product.with_deleted.friendly.find(params[:id]).active_subscriber_csv and return }
    end
    redirect_to( :action => :edit )
  end
end
