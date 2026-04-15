<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreProjectRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'type' => 'required|string',
            'difficulty_level' => 'required|integer|min:1|max:5',
            'skills' => 'required|array|min:1',
            'skills.*.id' => 'required|exists:skills,id',
            'skills.*.weight' => 'required|numeric|min:0|max:1',
        ];
    }
}
