import dotenv from "dotenv";
import nodemailer from "nodemailer";

dotenv.config();

const emailUser = process.env.EMAIL_USER?.trim();
const emailAppPassword = process.env.EMAIL_APP_PASSWORD?.replace(/\s+/g, "").trim();
const notificationEmail = process.env.PAYMENT_NOTIFICATION_EMAIL?.trim();

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: emailUser,
        pass: emailAppPassword,
    },
});

const sendPaymentNotification = async ({
    gymName,
    gymId,
    ownerName,
    plan,
    amount,
    paymentId,
    paymentStatus,
}) => {
    const mailOptions = {
        from: emailUser,
        to: notificationEmail,
        subject: `New Gym Payment Submitted - ${gymName}`,
        html: `
      <h2>New Payment Notification</h2>

      <p><strong>Gym Name:</strong> ${gymName}</p>
      <p><strong>Gym ID:</strong> ${gymId}</p>
      <p><strong>Owner Name:</strong> ${ownerName}</p>
      <p><strong>Plan:</strong> ${plan}</p>
      <p><strong>Amount:</strong> ₹${amount}</p>
      <p><strong>Payment ID:</strong> ${paymentId}</p>
      <p><strong>Payment Status:</strong> ${paymentStatus}</p>

      <p>Please verify the payment manually.</p>
    `,
    };

    await transporter.sendMail(mailOptions);
};

const sendOwnerCredentialsEmail = async ({
    gymName,
    gymId,
    ownerName,
    plan,
    membershipStartDate,
    membershipEndDate,
    email,
}) => {
    const mailOptions = {
        from: emailUser,
        to: email,
        subject: `Gym Account Activated - ${gymName}`,
        html: `
      <h2>Welcome to ${gymName}</h2>

      <p>Hello <strong>${ownerName}</strong>,</p>

      <p>Your gym membership has been successfully activated.</p>

      <h3>Your Login Details</h3>

      <p><strong>Gym Name:</strong> ${gymName}</p>
      <p><strong>Gym ID:</strong> ${gymId}</p>

      <p>
        <strong>Password:</strong>
        Use the password you created during registration.
      </p>

      <p>
        For security reasons, your password is not included in this email.
      </p>

      <p>
        <strong>Login:</strong>
        <a href="YOUR_FRONTEND_LOGIN_URL" target="_blank">
          Login to GYMORA
        </a>
      </p>

      <p><strong>Plan:</strong> ${plan}</p>

      <h3>Membership Details</h3>

      <p><strong>Start Date:</strong> ${new Date(
            membershipStartDate
        ).toLocaleDateString()}</p>

      <p><strong>End Date:</strong> ${new Date(
            membershipEndDate
        ).toLocaleDateString()}</p>

      <p>You can now log in using your Gym ID and the password you created during registration.</p>

      <p>Please keep your login credentials secure.</p>
    `,
    };

    await transporter.sendMail(mailOptions);
};

const sendPasswordResetOTP = async ({
    email,
    ownerName,
    otp,
}) => {
    const mailOptions = {
        from: emailUser,
        to: email,
        subject: "Gym Account Password Reset OTP",
        html: `
            <h2>Password Reset Request</h2>

            <p>Hello <strong>${ownerName}</strong>,</p>

            <p>Your OTP for resetting your gym account password is:</p>

            <h2>${otp}</h2>

            <p>This OTP is valid for <strong>10 minutes</strong>.</p>

            <p>If you did not request a password reset, please ignore this email.</p>
        `,
    };

    await transporter.sendMail(mailOptions);
};

export {
    sendPaymentNotification,
    sendOwnerCredentialsEmail,
    sendPasswordResetOTP,
};