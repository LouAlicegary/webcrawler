class OnlineResource < ActiveRecord::Base
  validates_uniqueness_of :link
  belongs_to :website
end
