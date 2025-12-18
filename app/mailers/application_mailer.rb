class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  default reply_to: "Suporte <fabriciosan47@gmail.com>"
  layout "mailer"
end
