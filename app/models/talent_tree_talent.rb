class TalentTreeTalent < ApplicationRecord
  belongs_to :talent_tree
  belongs_to :talent

  has_many :src_connections, class_name: 'TalentConnection', foreign_key: 'src_talent_id'
  has_many :dest_connections, class_name: 'TalentConnection', foreign_key: 'dest_talent_id'
end
