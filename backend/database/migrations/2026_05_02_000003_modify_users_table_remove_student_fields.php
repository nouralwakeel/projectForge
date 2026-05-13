<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['major_id']);
            $table->dropColumn([
                'student_id',
                'first_name',
                'last_name',
                'gender',
                'date_of_birth',
                'major_id',
                'academic_level',
            ]);
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('student_id')->unique();
            $table->string('first_name');
            $table->string('last_name');
            $table->enum('gender', ['male', 'female']);
            $table->date('date_of_birth');
            $table->foreignId('major_id')->nullable()->constrained('majors')->onDelete('set null');
            $table->integer('academic_level')->default(1);
        });
    }
};
