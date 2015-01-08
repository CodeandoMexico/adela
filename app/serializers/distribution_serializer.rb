class DistributionSerializer < ActiveModel::Serializer
  attributes  :title,
              :description,
              :license,
              :downloadURL,
              :mediaType,
              :format,
              :byteSize,
              # These are dcat:Dataset fields we're adding to dcat:Distribution
              :temporal,
              :spatial,
              :accrualPeriodicity

  def license
    "http://datos.gob.mx/libreusomx/"
  end
end
