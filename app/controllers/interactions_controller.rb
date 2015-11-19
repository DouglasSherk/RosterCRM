class InteractionsController < ApplicationController
  before_action :set_customer
  load_and_authorize_resource only: [:show, :edit, :update, :destroy]

  # GET /customer/1/interactions
  # GET /customer/1/interactions.json
  def index
    redirect_to @customer
  end

  # GET /customer/1/interactions/1
  # GET /customer/1/interactions/1.json
  def show
    redirect_to @customer
  end

  # GET /customers/1/interactions/new
  def new
    @interaction = Interaction.new
  end

  # GET /customer/1/interactions/1/edit
  def edit
  end

  # POST /customer/1/interactions
  # POST /customer/1/interactions.json
  def create
    @interaction = Interaction.new(interaction_params)
    @interaction.customer = @customer

    respond_to do |format|
      if @interaction.save
        check_next_contact
        format.html { redirect_to [@customer, @interaction], notice: 'Interaction was successfully created.' }
        format.json { render :show, status: :created, location: @interaction }
      else
        format.html { render :new }
        format.json { render json: @interaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer/1/interactions/1
  # PATCH/PUT /customer/1/interactions/1.json
  def update
    respond_to do |format|
      if @interaction.update(interaction_params)
        check_next_contact
        format.html { redirect_to [@customer, @interaction], notice: 'Interaction was successfully updated.' }
        format.json { render :show, status: :ok, location: @interaction }
      else
        format.html { render :edit }
        format.json { render json: @interaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer/1/interactions/1
  # DELETE /customer/1/interactions/1.json
  def destroy
    @interaction.destroy
    respond_to do |format|
      format.html { redirect_to @customer, notice: 'Interaction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_customer
      @customer = Customer.find(params[:customer_id])
      authorize! :read, @customer
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interaction_params
      params.require(:interaction).permit(:time, :mode, :description)
    end

    def check_next_contact
      if @interaction.time > DateTime.now
        @customer.next_contact = DateTime.now if @interaction.time > DateTime.now
        @customer.save
      end
    end
end
