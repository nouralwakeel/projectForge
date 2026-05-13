<?php

namespace Database\Factories;

use App\Models\Student;
use App\Models\User;
use App\Models\Major;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Student>
 */
class StudentFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'stud_num' => fake()->unique()->numerify('STU-#####'),
            'first_name' => fake()->firstName(),
            'last_name' => fake()->lastName(),
            'gender' => fake()->randomElement(['male', 'female']),
            'date_of_birth' => fake()->dateTimeBetween('-30 years', '-18 years'),
            'major_id' => null,
        ];
    }
}
