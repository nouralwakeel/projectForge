<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required_unless:role,student|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'sometimes|in:student,advisor,admin',
            'stud_num' => 'required_if:role,student|string|unique:students,stud_num',
            'first_name' => 'required_if:role,student|string|max:255',
            'last_name' => 'required_if:role,student|string|max:255',
            'gender' => 'required_if:role,student|in:male,female',
            'date_of_birth' => 'required_if:role,student|date',
            'major_id' => 'required_if:role,student|exists:majors,id',
        ];
    }
}
