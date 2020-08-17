const nodemailer = require('nodemailer')
const dotenv = require('dotenv')
const pug = require('pug')
const htmlToText = require('html-to-text')
dotenv.config({ path: './config.env' })

module.exports = class Email {
   constructor(user,url){
      this.to=user.email;
      this.firstName = user.name.split(' ')[0];
      this.url = url;
      this.from = `Psyclog <${process.env.EMAIL_FROM}>`;
   }

   newTransport(){
      
      if(process.env.NODE_ENV === 'production'){
         //sendgrid
         return nodemailer.createTransport({
            service:'SendGrid',
            auth: {
               user:process.env.SENDGRID_USERNAME,
               pass:process.env.SENDGRID_PASSWORD
            }
         });
      }

      return nodemailer.createTransport({
         host: process.env.EMAIL_HOST,
         port: process.env.EMAIL_PORT,
         auth: {
            user: process.env.EMAIL_USERNAME,
            pass: process.env.EMAIL_PASSWORD
         }
      });
   }
   //send actual email
   async send(template,subject){
      //1-Render html pug
      const html =  pug.renderFile(`${__dirname}/../views/email/${template}.pug`,{
         firstName:this.firstName,
         url:this.url,
         subject
      });

      //2-define email options
      const mailOptions = {
         from: this.from,
         to:this.to,
         subject,
         text: htmlToText.fromString(html),
         html
      };

      //3-create transport and send email
      await this.newTransport().sendMail(mailOptions);
   }
   
   async sendWelcome(){
      await this.send('welcome','Welcome to the Pysclog Family!');
   }

   async sendPasswordReset(){
      await this.send('passwordReset','Your Password reset token (valid for only 10 minutes)!');
   }
};
