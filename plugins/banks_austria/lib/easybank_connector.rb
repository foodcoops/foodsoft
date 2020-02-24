require 'base_connector'

class EasybankConnector < BaseConnector

  def login(dn, pin)
    @agent = Mechanize.new
    @agent.get("https://ebanking.easybank.at/InternetBanking/InternetBanking?d=login&svc=EASYBANK&ui=html&lang=de")

    loginForm = @agent.page.form_with(:name => "loginForm")
    loginForm.field_with(:name => "dn").value = dn
    loginForm.field_with(:name => "pin").value = pin

    @page = loginForm.submit
  end

  def balance(iban)
    @page.search("#" + iban2account(iban)).each do |tr|
      tds = tr.css("td")
      return BigDecimal(tds[9].content.gsub(/[^0-9]*EUR/, "").gsub(/\./, "").gsub(/,/, ".").strip)
    end
  end

  def transactions(iban, last = nil, &block)
    last = "000000001" if last.nil?

    set_active_account(iban)
    rows_per_page = 50

    while parse_transactions(true, last) do
      raise "Last item can not be found" if rows_per_page > 200
      set_rows_per_page(rows_per_page)
      rows_per_page *= 2
    end

    items = []
    parse_transactions(false, last) { |t| items << t }
    set_rows_per_page(30)

    items.sort_by! { |item| item[:id] }
    items.each &block
    items.last && items.last[:id]
  end

  def logout
    navigationform = @page.form_with(:name => "navigationform")
    navigationform.field_with(name: "d").value = "logoutredirect"
    navigationform.submit
  end

  private

  def iban2account(iban)
    iban[-11,11]
  end

  def set_active_account(iban)
    financeOverviewForm = @page.form_with(:name => "financeOverviewForm")
    financeOverviewForm.field_with(:name => "activeaccount").value = iban2account(iban)
    financeOverviewForm.field_with(:name => "d").value = "transactions"
    @page = financeOverviewForm.submit
  end

  def set_rows_per_page(value)
    transactionSearchForm = @page.form_with(:name => "transactionSearchForm")
    transactionSearchForm.field_with(:name => "rowsPerPage").value = value
    navigationform = transactionSearchForm.submit.form_with(:name => "navigationform")
    navigationform.field_with(:name => "d").value = "transactions"
    @page = navigationform.submit
  end

  def parse_transactions(check_only, last)
    @page.search("#exchange-details tbody").each do |tbody|
      tbody.search("tr").each do |tr|
        tds = tr.css("td")

        lines = [tds[3].children[0].content]
        lines << tds[3].children[2].content if tds[3].children[2]
        lines << tds[3].children[4].content if tds[3].children[4]
        lines << tds[3].children[6].content if tds[3].children[6]
        lines << tds[3].children[8].content if tds[3].children[8]

        lines_offset = 0
        first_line = lines[0]
        while lines_offset < lines.count
          m = /^((?<text>.*) )?(?<type>[A-Z]{2})\/(?<id>\d{9})$/.match(first_line)
          break if m
          lines_offset += 1
          first_line += ' ' + lines[lines_offset]
        end

        raise "Can not parse ID=#{first_line}" unless m
        return false if m[:id] == last
        next if check_only

        transaction = {
          id: m[:id],
          type: m[:type],
          booking_date: Date.strptime(tds[1].content, "%d.%m.%Y"),
          value_date: Date.strptime(tds[5].content, "%d.%m.%Y"),
          amount: BigDecimal(tds[9].content.gsub(/\./, "").gsub(/,/, ".")),
          raw: lines.join("\n")
        }

        if m[:text]
          transaction[:text] = m[:text].strip

          if lines.count > (lines_offset+1)
            m = /^((?<bic>[A-Z]{6}[A-Z0-9]{2}[A-Z0-9]{3}?) )?(?<iban>[A-Z]{2}\d{2}[A-Z0-9]{1,30})$/.match(lines[lines_offset+1])
            if m
              transaction[:bic] = m[:bic]
              transaction[:iban] = m[:iban]
              transaction[:name] = lines[lines_offset+2]
            else
              m = /^(((?<bic>[A-Z]{6}[A-Z0-9]{2}[A-Z0-9]{3}?) )?(?<iban>[A-Z]{2}\d{2}[A-Z0-9]{1,30}) )?(?<name>.*)$/.match(lines[lines_offset+1])
              transaction[:bic] = m[:bic]
              transaction[:iban] = m[:iban]
              transaction[:name] = m[:name]
              transaction[:text2] = lines[lines_offset+2] unless lines[lines_offset+2].nil?
            end

            m = /^Gutschrift \u00DCberweisung (?<reference>.*)$/.match(transaction[:text])
            if m
              transaction[:reference] = m[:reference].strip
            elsif transaction[:type] != "IG" && transaction[:type] != "ZE"
              if transaction[:text2]
                transaction[:reference2] = transaction[:text2]
              else
                transaction[:reference] = transaction[:text]
              end
            end

            details = tds[11].css("a")[0]
            if details
              transaction[:reference] = nil
              transaction[:reference2] = nil

              url = details["onclick"].split("'")[1]
              param = CGI.parse(URI.parse(url).query)
              d = param["d"]
              d = d.join("") if d.class == Array
              if d == "image"
                transaction[:image] = @agent.get(@agent.get(url).search("body>div>img")[0]["src"]).content.read
              else
                supplementtext = @agent.get(url).search("td.supplementtext").map { |td| td.content }
                transaction[:receipt] = supplementtext.join("\n")
                m = /^(?<reference>[^\s].{39}) EUR\-*(?<amount>\d+,\d{2})\s*$/.match(supplementtext[22])
                if m
                  transaction[:reference] = m[:reference].strip
                else
                  for i in 6..10
                    text = supplementtext[i].strip
                    if text != ""
                      transaction[:reference2] = text
                      break
                    end
                  end
                end
              end
            end
          end
        else
          transaction[:text] = lines[lines_offset+1].strip
        end

        yield transaction
      end
    end

    return true
  end
end
