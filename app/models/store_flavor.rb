class StoreFlavor < ActiveRecord::Base
  include CreameryHelpers::Validations
  # relationships
  belongs_to :store
  belongs_to :flavor
  # validations
  validates_presence_of :store_id, :flavor_id
  validate :store_is_active_in_system, on: :create
  validate :flavor_is_active_in_system, on: :create

  scope :alphabetical ->
  scope :for_store,   ->(store_id) { where("store_id = ?", store_id) }
  scope :for_flavor,  ->(flavor_id) { where("flavor_id = ?", flavor_id) }
  private  
  
  def store_is_active_in_system
    is_active_in_system(:store)
  end

  def flavor_is_active_in_system
    is_active_in_system(:flavor)
  end
end
