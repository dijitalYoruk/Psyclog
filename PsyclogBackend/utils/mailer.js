const nodemailer = require('nodemailer')
const dotenv = require('dotenv')
const pug = require('pug')
const htmlToText = require('html-to-text')
dotenv.config({ path: './config.env' })

const newTransport = async =>{
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
const send = async (user, url,template,subject) =>{
   this.to=user.email;
   this.firstName = user.name.split(' ')[0];
   this.url = url;
   this.from = `Psyclog <${process.env.EMAIL_FROM}>`;

   //1-Render html pug
   const html =  pug.renderFile(`./views/email/${template}.pug`,{
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
   await newTransport().sendMail(mailOptions);
}

const sendPasswordReset = async (user, resetURL) => { 
      await send(user, resetURL,'passwordReset',__('reset_subject'));
}

const sendAccountVerification = async (user, verificationURL) => { 
   await send(user, verificationURL,'verification',__('verification_subject'));
}

module.exports = {
   sendPasswordReset,
   sendAccountVerification
}