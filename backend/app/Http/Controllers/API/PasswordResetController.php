<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class PasswordResetController extends Controller
{
    private const OTP_TTL_MINUTES = 10;

    private const MAX_ATTEMPTS = 5;

    /**
     * Issue a 6-digit OTP for the given email. Always responds success so the
     * endpoint doesn't reveal whether an account exists. Outside production the
     * code is returned in `dev_otp` (and logged) so it works without real SMTP.
     */
    public function forgot(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $email = strtolower(trim($request->email));
        $user = User::where('email', $email)->first();
        $devOtp = null;

        if ($user) {
            $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            DB::table('password_otps')->where('email', $email)->delete();
            DB::table('password_otps')->insert([
                'email' => $email,
                'otp_hash' => Hash::make($otp),
                'attempts' => 0,
                'expires_at' => Carbon::now()->addMinutes(self::OTP_TTL_MINUTES),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]);

            $this->sendOtp($email, $otp);

            if (! app()->isProduction()) {
                $devOtp = $otp;
            }
        }

        $data = ['expires_in_minutes' => self::OTP_TTL_MINUTES];
        if ($devOtp !== null) {
            $data['dev_otp'] = $devOtp;
        }

        return response()->json([
            'success' => true,
            'message' => 'إذا كان البريد مسجّلاً فستصلك رسالة تتضمّن رمز التحقق.',
            'data' => $data,
        ]);
    }

    /**
     * Verify the OTP and set a new password.
     */
    public function reset(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $email = strtolower(trim($request->email));

        $record = DB::table('password_otps')->where('email', $email)->latest('id')->first();

        if (! $record) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد طلب إعادة تعيين لهذا البريد. اطلب رمزاً جديداً.',
            ], 422);
        }

        if (Carbon::parse($record->expires_at)->isPast()) {
            DB::table('password_otps')->where('email', $email)->delete();

            return response()->json([
                'success' => false,
                'message' => 'انتهت صلاحية الرمز. اطلب رمزاً جديداً.',
            ], 422);
        }

        if ($record->attempts >= self::MAX_ATTEMPTS) {
            DB::table('password_otps')->where('email', $email)->delete();

            return response()->json([
                'success' => false,
                'message' => 'تم تجاوز عدد المحاولات المسموح. اطلب رمزاً جديداً.',
            ], 429);
        }

        if (! Hash::check($request->otp, $record->otp_hash)) {
            DB::table('password_otps')->where('id', $record->id)->increment('attempts');

            return response()->json([
                'success' => false,
                'message' => 'رمز التحقق غير صحيح.',
            ], 422);
        }

        $user = User::where('email', $email)->first();
        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'تعذّر إكمال العملية.',
            ], 422);
        }

        $user->password = Hash::make($request->password);
        $user->save();
        $user->tokens()->delete();

        DB::table('password_otps')->where('email', $email)->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن.',
        ]);
    }

    private function sendOtp(string $email, string $otp): void
    {
        try {
            Mail::raw(
                "رمز التحقق لإعادة تعيين كلمة المرور في ProjectForge هو: {$otp}\nصالح لمدة ".self::OTP_TTL_MINUTES.' دقائق.',
                function ($message) use ($email) {
                    $message->to($email)->subject('رمز إعادة تعيين كلمة المرور - ProjectForge');
                }
            );
        } catch (\Throwable $e) {
            // SMTP may be unconfigured (dev): the code is still returned via dev_otp.
            Log::warning('Password OTP email failed to send', ['email' => $email, 'error' => $e->getMessage()]);
        }
    }
}
