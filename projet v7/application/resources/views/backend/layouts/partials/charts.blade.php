    <!-- Chart.js Script -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const ctx = document.getElementById('userChart').getContext('2d');
        const userChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: {!! json_encode($dates) !!},
                datasets: [{
                        label: 'Utilisateurs Vérifiés',
                        data: {!! json_encode($verifiedCounts) !!},
                        borderColor: 'rgb(54, 162, 235)',
                        backgroundColor: 'rgba(54, 162, 235, 0.2)',
                        tension: 0.3,
                        fill: true
                    },
                    {
                        label: 'Utilisateurs Non Vérifiés',
                        data: {!! json_encode($unverifiedCounts) !!},
                        borderColor: 'rgb(255, 99, 132)',
                        backgroundColor: 'rgba(255, 99, 132, 0.2)',
                        tension: 0.3,
                        fill: true
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                    }
                },
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Date'
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Nombre d\'utilisateurs'
                        }
                    }
                }
            }
        });

        const ctxCandidat = document.getElementById('candidatChart').getContext('2d');
        const candidatChart = new Chart(ctxCandidat, {
            type: 'bar',
            data: {
                labels: {!! json_encode($dates) !!},
                datasets: [{
                    label: 'Candidats Ajoutés',
                    data: {!! json_encode($candidatCounts) !!},
                    backgroundColor: 'rgba(75, 192, 192, 0.6)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false
                    }
                },
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Date'
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Nombre de candidats'
                        }
                    }
                }
            }
        });

        const ctxCategoryPie = document.getElementById('categoryPieChart').getContext('2d');
        const categoryPieChart = new Chart(ctxCategoryPie, {
            type: 'pie',
            data: {
                labels: {!! json_encode($categoryLabels) !!},
                datasets: [{
                    label: 'Nombre de Candidats',
                    data: {!! json_encode($categoryCounts) !!},
                    backgroundColor: [
                        '#FF6384',
                        '#36A2EB',
                        '#FFCE56',
                        '#4BC0C0',
                        '#9966FF',
                        '#FF9F40',
                        '#C9CBCF',
                        '#8A9B0F',
                        '#D2691E',
                        '#00CED1',
                        '#9400D3',
                        '#FFD700',
                        '#FF4500',
                        '#228B22',
                        '#708090',
                    ],
                    borderColor: '#fff',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right',
                    },
                    tooltip: {
                        enabled: true,
                    }
                }
            }
        });
        const dates = @json($dates);

        const offerCategoryLabels = @json($offerCategoryLabels);
        const offerCategoryCounts = @json($offerCategoryCounts);

        // Job Offers Added Chart
        const ctxJobOffer = document.getElementById('jobOfferChart').getContext('2d');
        const jobOfferChart = new Chart(ctxJobOffer, {
            type: 'line',
            data: {
                labels: {!! json_encode($dates) !!},
                datasets: [{
                        label: 'En attente',
                        data: {!! json_encode($offerPendingCounts) !!},
                        borderColor: 'rgba(255, 205, 86, 1)',
                        backgroundColor: 'rgba(255, 205, 86, 0.2)',
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'Acceptées',
                        data: {!! json_encode($offerAcceptedCounts) !!},
                        borderColor: 'rgba(75, 192, 192, 1)',
                        backgroundColor: 'rgba(75, 192, 192, 0.2)',
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'Rejetées',
                        data: {!! json_encode($offerRejectedCounts) !!},
                        borderColor: 'rgba(255, 99, 132, 1)',
                        backgroundColor: 'rgba(255, 99, 132, 0.2)',
                        fill: true,
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false
                    }
                },
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Date'
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: "Nombre d'offres"
                        }
                    }
                }
            }
        });

        // Job Offers per Category Pie Chart
        const ctxOfferCategoryPie = document.getElementById('offerCategoryPieChart').getContext('2d');
        const offerCategoryPieChart = new Chart(ctxOfferCategoryPie, {
            type: 'pie',
            data: {
                labels: {!! json_encode($offerCategoryLabels) !!},
                datasets: [{
                    label: "Nombre d'offres",
                    data: {!! json_encode($offerCategoryCounts) !!},
                    backgroundColor: [
                        '#FF6384',
                        '#36A2EB',
                        '#FFCE56',
                        '#4BC0C0',
                        '#9966FF',
                        '#FF9F40',
                        '#C9CBCF',
                        '#8A9B0F',
                        '#D2691E',
                        '#00CED1',
                        '#9400D3',
                        '#FFD700',
                        '#FF4500',
                        '#228B22',
                        '#708090',
                    ],
                    borderColor: '#fff',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right',
                    },
                    tooltip: {
                        enabled: true,
                    }
                }
            }
        });

    const offerRequestStatusChart = document.getElementById('offerRequestStatusChart').getContext('2d');

    new Chart(offerRequestStatusChart, {
        type: 'bar',
        data: {
            labels: [
                'Offres sans candidatures',
                'Offres avec candidatures en attente/refusées',
                'Offres avec candidatures acceptées'
            ],
            datasets: [{
                label: 'Nombre d\'offres',
                data: [
                    {{ $offersNoRequestsCount }},
                    {{ $offersPendingRejectedCount }},
                    {{ $offersAcceptedRequestCount }}
                ],
                backgroundColor: [
                    'rgba(54, 162, 235, 0.6)',
                    'rgba(255, 206, 86, 0.6)',
                    'rgba(75, 192, 192, 0.6)'
                ],
                borderColor: [
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 206, 86, 1)',
                    'rgba(75, 192, 192, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true,
                    precision: 0
                }
            }
        }
    });
    </script>
