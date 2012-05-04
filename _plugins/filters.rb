
module Jekyll

  module MyDateFilter

    def date_to_s(input)
      input.strftime('%Y-%m-%d')
    end
  end
end

Liquid::Template.register_filter(Jekyll::MyDateFilter)

