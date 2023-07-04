module Spree
  module ProductDecorator
    def self.prepended(base)
      base.before_update :automatic_association_of_taxon_edenred
    end

    # Association of edenred taxon to non-food taxons
    def automatic_association_of_taxon_edenred
      #return false unless Rails.env.production?

      taxon_edenred = Spree::Taxon.find(2089)
      arr_taxons = taxons_non_food - taxon_ids
      return true if taxon_ids.include?(taxon_edenred.id)

      if !arr_taxons.count.eql?(taxons_non_food.count) || by_rukafe?
        taxons << taxon_edenred
        return
      elsif taxon_ids.include?(taxon_edenred.id)
        classifications.map{ |c| c.delete if c.taxon_id.eql?(taxon_edenred.id) }
      end
    end

    def taxons_non_food
      [1349, 1350, 1351, 1943, 1492, 1493]
    end

    def by_rukafe?
      store_ids.include?(8)
    end
  end
end

::Spree::Product.prepend Spree::ProductDecorator
