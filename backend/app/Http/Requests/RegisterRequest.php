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
}
