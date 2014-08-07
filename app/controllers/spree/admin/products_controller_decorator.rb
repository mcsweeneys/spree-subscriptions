Spree::Admin::ProductsController.class_eval do
  def show
    session[:return_to] ||= request.referer
    respond_to do |format|
      format.csv do
        response.headers['Content-Disposition'] = 'attachment; filename="' + @product.name.parameterize + '--active-subscribers-as-of-' + Time.zone.now.strftime('%Y-%m-%d--%I-%M-%P') + '.csv"'
        render text: Spree::Product.with_deleted.friendly.find(params[:id]).active_subscriber_csv and return 
      end
    end
    redirect_to( :action => :edit )
  end
end
