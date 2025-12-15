class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  defult reply_to: 'Suporte "fabriciosan47@gmail.com"'
  layout "mailer"
end
