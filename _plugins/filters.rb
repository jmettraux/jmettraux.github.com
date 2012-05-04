
module Jmettraux

  module DateFilter

    def date_to_s(input)
      input.strftime('%Y-%m-%d')
    end
  end
end

Liquid::Template.register_filter(Jmettraux::DateFilter)

