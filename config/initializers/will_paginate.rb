module WillPaginate::I18nViewHelpers
  def will_paginate(collection, options = {})
    super(collection,
      options.merge(
        :previous_label => "&lt; #{I18n.t('will_paginate.previous')}",
        :next_label => "#{I18n.t('will_paginate.next')} &gt;"
        )
      )
  end
end

ActionView::Base.send(:include, WillPaginate::I18nViewHelpers)