class Job {
  final String id;
  final String jobTitle;
  final String? categoryName;
  final String jobLocation;
  final String salary;
  final String employerType;
  final String jobType;
  final String? logoUrl;

  Job({
    required this.id,
    required this.jobTitle,
    this.categoryName,
    required this.jobLocation,
    required this.salary,
    required this.employerType,
    this.logoUrl,
    required this.jobType,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
       id: json['id']?.toString() ?? '',
      jobTitle: json['job_title'] ?? '',
      categoryName: json['category']?['name'],
      jobLocation: json['job_location'] ?? '',
      salary: json['salary'] ?? '',
      employerType: json['employer_type'] ?? '',
      jobType: json['job_type']?? '',
    );
  }
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'job_title': jobTitle,
    'category': {'name': categoryName},
    'job_location': jobLocation,
    'salary': salary,
    'employer_type': employerType,
    'job_type': jobType,
  };
}


}
