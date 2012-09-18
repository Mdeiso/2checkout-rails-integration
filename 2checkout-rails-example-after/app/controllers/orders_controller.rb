class OrdersController < AdminController
  skip_filter :authenticate, :only => [:notification]

  def index
    @orders = Order.all
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def edit
    @order = Order.find(params[:id])
  end

  def create
    @order = Order.new(params[:total, :card_holder_name, :order_number])
    flash[:notice] = "Order Created Successfully."
  end

  def update
    @order = Order.find(params[:id])
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to orders_path
  end

  def notification
    @notification = Twocheckout::Ins.request({:credentials => {'sid' => 1817037, 'secret' => 'tango'}, :params => params})
    @notification = JSON.parse(notification)
    @order = Order.find_by_order_number(params['sale_id'])
    if params['message_type'] == "FRAUD_STATUS_CHANGED"
      begin
        if @notification['code'] == "PASS" and params['fraud_status'] == "pass"
          @order.status = "success"
          render :text =>"Fraud Status Passed"
        else
          @order.status = "failed"
          render :text =>"Fraud Status Failed or MD5 Hash does not match!"
        end
        ensure
        @order.save
      end
    end
  end

  def refund
    @order = Order.find(params[:id])
    Twocheckout.api_credentials=({'username' => 'APIuser1817037', 'password' => 'APIpass1817037'})
    @response = Twocheckout::Sale.refund({'sale_id' => @order.order_number, 'comment' => "Item(s) not available", 'category' => 6})
    @response = JSON.parse(@response)
    logger.info(@response)
    if @response['response_code'] == "OK"
      @order.status = "refunded"
      @order.save
      flash[:notice] = @response['response_message']
      redirect_to orders_path
    else
      flash[:notice] = @response['errors'][0]['message']
      redirect_to orders_path
    end
  end
end
