class Store < ActiveRecord::Base
  # Callbacks
  before_save :reformat_phone
  before_destroy :is_destroyable?
  after_rollback :convert_to_inactive
  
  # Relationships
  has_many :assignments
  has_many :employees, through: :assignments  
  has_many :shifts, through: :assignments
  has_many :store_flavors
  has_many :flavors, through: :store_flavors
  
  # Validations
  # make sure required fields are present
  validates_presence_of :name, :street, :zip
  # if state is given, must be one of the choices given (no hacking this field)
  validates_inclusion_of :state, :in => %w[PA OH WV], message: "is not an option"
  # if zip included, it must be 5 digits only
  validates_format_of :zip, with: /\A\d{5}\z/, message: "should be five digits long"
  # phone can have dashes, spaces, dots and parens, but must be 10 digits
  validates_format_of :phone, with: /\A\(?\d{3}\)?[-. ]?\d{3}[-.]?\d{4}\z/, message: "should be 10 digits (area code needed) and delimited with dashes only"
  # make sure stores have unique names
  validates_uniqueness_of :name
  
  # Scopes
  scope :alphabetical, -> { order('name') }
  scope :active,       -> { where(active: true) }
  scope :inactive,     -> { where(active: false) }
  
  
  # Misc constants
  STATES_LIST = [['Ohio', 'OH'],['Pennsylvania', 'PA'],['West Virginia', 'WV']]
  
  # Other methods
  def get_store_coordinates
    coord = Geocoder.coordinates("#{street}, #{zip}")
    if coord
      self.latitude = coord[0]
      self.longitude = coord[1]
      self.save
    end
    coord
  end

  def create_map_link(zoom=12,width=500,height=500)
    markers = ""; i = 1
    markers += "&markers=color:red%7Ccolor:red%7Clabel:#{i}%7C#{self.latitude},#{self.longitude}"
    map = "http://maps.google.com/maps/api/staticmap?center= #{latitude},#{longitude}&zoom=#{zoom}&size=#{width}x#{height}&maptype=roadmap&sensor=false"
  end
  
  # Callback code
  # -----------------------------
  private
  # We need to strip non-digits before saving to db
  def reformat_phone
    phone = self.phone.to_s  # change to string in case input as all numbers 
    phone.gsub!(/[^0-9]/,"") # strip all non-digits
    self.phone = phone       # reset self.phone to new string
  end

  def is_destroyable?
    @destroyable = false
  end
  
  def convert_to_inactive
    make_inactive if !@destroyable.nil? && @destroyable == false
    @destroyable = nil
  end

  def make_inactive
    self.update_attribute(:active, false)
  end

end
