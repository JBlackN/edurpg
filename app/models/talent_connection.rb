class TalentConnection < ApplicationRecord
  belongs_to :src_talent, class_name: 'TalentTreeTalent'
  belongs_to :dest_talent, class_name: 'TalentTreeTalent'
end
