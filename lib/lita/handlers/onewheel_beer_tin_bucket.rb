require 'rest-client'
require 'nokogiri'
require 'sanitize'
require 'lita-onewheel-beer-base'

module Lita
  module Handlers
    class OnewheelBeerTinBucket < OnewheelBeerBase
      route /^tinbucket$/i,
            :taps_list,
            command: true,
            help: {'taps' => 'Display the current Tin Bucket taps.'}

      route /^tinbucket ([\w ]+)$/i,
            :taps_deets,
            command: true,
            help: {'taps 4' => 'Display the tap 4 deets, including prices.'}

      route /^tinbucket ([<>=\w.\s]+)%$/i,
            :taps_by_abv,
            command: true,
            help: {'taps >4%' => 'Display beers over 4% ABV.'}

      route /^tinbucket ([<>=\$\w.\s]+)$/i,
            :taps_by_price,
            command: true,
            help: {'taps <$5' => 'Display beers under $5.'}

      route /^tinbucket (roulette|random|rand|ran|ra|r)$/i,
            :taps_by_random,
            command: true,
            help: {'taps roulette' => 'Can\'t decide?  Let me do it for you!'}

      route /^tinbucketabvlow$/i,
            :taps_low_abv,
            command: true,
            help: {'tapslow' => 'Show me the lowest abv keg.'}

      route /^tinbucketabvhigh$/i,
            :taps_high_abv,
            command: true,
            help: {'tapslow' => 'Show me the highest abv keg.'}

      def send_response(tap, datum, response)
        reply = "tinbucket tap #{tap}) #{get_tap_type_text(datum[:type])}"
        # reply += "#{datum[:brewery]} "
        reply += "#{datum[:name]} "
        # reply += "- #{datum[:desc]}, "
        # reply += "Served in a #{datum[1]['glass']} glass.  "
        # reply += "#{datum[:remaining]}"
        reply += "#{datum[:abv]}%, "
        reply += "$#{datum[:price].to_s.sub '.0', ''}"

        Lita.logger.info "send_response: Replying with #{reply}"

        response.reply reply
      end

      def get_source
        Lita.logger.debug 'get_source started'
        unless (response = redis.get('page_response'))
          Lita.logger.info 'No cached result found, fetching.'
          response = RestClient.get('http://tinbucketbar.com/menu')
          redis.setex('page_response', 1800, response)
        end
        parse_response response
      end

      # This is the worker bee- decoding the html into our "standard" document.
      # Future implementations could simply override this implementation-specific
      # code to help this grow more widely.
      def parse_response(response)
        Lita.logger.debug 'parse_response started.'
        gimme_what_you_got = {}
        noko = Nokogiri.HTML response
        noko.css('table.table tbody tr').each_with_index do |beer_node, index|
          # gimme_what_you_got
          tap_name = (index + 1).to_s

          brewery = beer_node.css('td')[2].children.to_s
          beer_name = beer_node.css('td')[0].children.text.to_s
          beer_type = beer_name.match(/\s*-\s*\w+$/).to_s
          beer_type.sub! /\s+-\s+/, ''
          # beer_desc = get_beer_desc(beer_node)
          abv = beer_node.css('td')[4].children.to_s
          full_text_search = "#{brewery} #{beer_name.to_s.gsub /(\d+|')/, ''}"  # #{beer_desc.to_s.gsub /\d+\.*\d*%*/, ''}
          price_node = beer_node.css('td')[1].children.to_s
          price = (price_node.sub /\$/, '').to_f

          Lita.logger.debug "Price #{price}"

          gimme_what_you_got[tap_name] = {
          #     type: tap_type,
          #     remaining: remaining,
              brewery: brewery.to_s,
              name: beer_name.to_s,
              desc: beer_type.to_s,
              abv: abv.to_f,
              price: price,
              search: full_text_search
          }
        end
        # puts gimme_what_you_got.inspect

        gimme_what_you_got
      end

      Lita.register_handler(self)
    end
  end
end
