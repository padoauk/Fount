class CellsController < ApplicationController
  before_action :set_cell, only: [:show, :edit, :update, :destroy]

  # GET /cells
  # GET /cells.json
  def index
    set_packet
    if @packet then
      @cells = Cell.where("packet_id = ?",@packet.id)
    else
      @cells = Cell.all
    end
  end

  # GET /cells/1
  # GET /cells/1.json
  def show
    set_cell
  end

  # GET /cells/new
  def new
    @cell = Cell.new
    set_packet
    if @packet then
      @cell.packet_id = @packet.id
    end
  end

  # GET /cells/1/edit
  def edit
    set_cell
  end

  # POST /cells
  # POST /cells.json
  def create
    @cell = Cell.new(cell_params)

    respond_to do |format|
      if @cell.save
        format.html { redirect_to @cell, notice: 'Cell was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cell }
      else
        format.html { render action: 'new' }
        format.json { render json: @cell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cells/1
  # PATCH/PUT /cells/1.json
  def update
    respond_to do |format|
      if @cell.update(cell_params)
        format.html { redirect_to @cell, notice: 'Cell was successfully updated.' }
        format.json { head :no_content }
        PacketManager.instance.update_cell(@cell)
      else
        format.html { render action: 'edit' }
        format.json { render json: @cell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cells/1
  # DELETE /cells/1.json
  def destroy
    packet_id = @cell.packet_id
    @cell.destroy
    respond_to do |format|
      format.html { redirect_to cells_url }
      format.json { head :no_content }
    end
    PacketManager.instance.update_packet( Packet.find(packet_id) )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cell
      @cell = Cell.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cell_params
      params.require(:cell).permit(:name, :cell_type, :size, :byte_pos, :bit_pos, :packet_id, :val)
    end

    def set_packet
      if 0 < params[:packet_id].to_i then
        pid = params[:packet_id]
        @packet = Packet.find(pid)
      end
    end
end
