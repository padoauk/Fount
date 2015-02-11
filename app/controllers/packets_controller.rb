class PacketsController < ApplicationController
  before_action :set_packet, only: [:show, :edit, :update, :destroy]

  # GET /packets
  # GET /packets.json
  def index
    @packets = Packet.all
  end

  # GET /packets/1
  # GET /packets/1.json
  def show
  end

  # GET /packets/new
  def new
    @packet = Packet.new
  end

  # GET /packets/1/edit
  def edit
  end

  # POST /packets
  # POST /packets.json
  def create
    @packet = Packet.new(packet_params)

    respond_to do |format|
      if @packet.save
        format.html { redirect_to @packet, notice: 'Packet was successfully created.' }
        format.json { render action: 'show', status: :created, location: @packet }
      else
        format.html { render action: 'new' }
        format.json { render json: @packet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packets/1
  # PATCH/PUT /packets/1.json
  def update
    respond_to do |format|
      if @packet.update(packet_params)
        format.html { redirect_to @packet, notice: 'Packet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @packet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packets/1
  # DELETE /packets/1.json
  def destroy
    @packet.destroy
    respond_to do |format|
      format.html { redirect_to packets_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_packet
      @packet = Packet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def packet_params
      params.require(:packet).permit(:name_space, :name, :version, :is_active, :period)
    end
end
