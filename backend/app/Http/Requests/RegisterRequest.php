<?php

namespace App\Http\Requests;

class RegisterRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email'          => 'required|email|unique:users,email',
            'password'       => 'required|string|min:8|confirmed',
            'role'           => 'sometimes|in:student,advisor,admin',
            'stud_num'       => 'required|string|unique:students,stud_num',
            'first_name'     => 'required|string|max:255',
            'last_name'      => 'required|string|max:255',
            'gender'         => 'required|in:male,female',
            'date_of_birth'  => 'required|date|before:today',
            'major_id'       => 'required|exists:majors,id',
        ];
    }

    public function messages(): array
    {
        return [
            'email.required'         => 'البريد الإلكتروني مطلوب',
            'email.email'            => 'صيغة البريد الإلكتروني غير صحيحة',
            'email.unique'           => 'هذا البريد الإلكتروني مسجّل مسبقاً',
            'password.required'      => 'كلمة المرور مطلوبة',
            'password.min'           => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
            'password.confirmed'     => 'كلمة المرور وتأكيدها غير متطابقتين',
            'stud_num.required'      => 'الرقم الجامعي مطلوب',
            'stud_num.unique'        => 'هذا الرقم الجامعي مسجّل مسبقاً',
            'first_name.required'    => 'الاسم الأول مطلوب',
            'last_name.required'     => 'اسم العائلة مطلوب',
            'gender.required'        => 'الجنس مطلوب',
            'gender.in'              => 'قيمة الجنس غير صحيحة',
            'date_of_birth.required' => 'تاريخ الميلاد مطلوب',
            'date_of_birth.date'     => 'صيغة تاريخ الميلاد غير صحيحة',
            'date_of_birth.before'   => 'تاريخ الميلاد يجب أن يكون قبل اليوم',
            'major_id.required'      => 'التخصص الجامعي مطلوب',
            'major_id.exists'        => 'التخصص المحدد غير موجود',
        ];
    }
}
